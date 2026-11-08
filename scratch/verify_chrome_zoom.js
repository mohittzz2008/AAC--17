const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 8099;
const BUILD_DIR = path.join(__dirname, '..', 'build', 'web');

// Simple static HTTP server for build/web
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
};

const server = http.createServer((req, res) => {
  let filePath = path.join(BUILD_DIR, req.url === '/' ? 'index.html' : req.url.split('?')[0]);
  if (!fs.existsSync(filePath)) {
    filePath = path.join(BUILD_DIR, 'index.html');
  }
  const ext = path.extname(filePath);
  const contentType = mimeTypes[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(500);
      res.end('Error loading file');
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    }
  });
});

async function runVerification() {
  server.listen(PORT);
  console.log(`[1] Local HTTP server serving build/web on http://localhost:${PORT}`);

  const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
  const chromeArgs = [
    '--remote-debugging-port=9222',
    '--headless=new',
    '--window-size=1440,900',
    '--disable-gpu-shader-disk-cache',
    '--no-first-run',
    '--no-default-browser-check',
    `http://localhost:${PORT}`,
  ];

  console.log(`[2] Launching Google Chrome...`);
  const chromeProcess = spawn(chromePath, chromeArgs);

  // Wait 3 seconds for Chrome to bind port 9222
  await new Promise(r => setTimeout(r, 3000));

  // Fetch debugging target
  const targetsRes = await fetch('http://localhost:9222/json');
  const targets = await targetsRes.json();
  const pageTarget = targets.find(t => t.type === 'page');

  if (!pageTarget || !pageTarget.webSocketDebuggerUrl) {
    throw new Error('No page target found on Chrome remote debugging port');
  }

  console.log(`[3] Connected to Chrome DevTools WebSocket: ${pageTarget.webSocketDebuggerUrl}`);
  const ws = new WebSocket(pageTarget.webSocketDebuggerUrl);

  let messageId = 1;
  const pendingRequests = new Map();
  const consoleMessages = [];

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    if (data.id && pendingRequests.has(data.id)) {
      const resolver = pendingRequests.get(data.id);
      pendingRequests.delete(data.id);
      resolver(data.result);
    }
    if (data.method === 'Runtime.consoleAPICalled') {
      const text = data.params.args.map(a => a.value).join(' ');
      consoleMessages.push(text);
      console.log(`  [Chrome Console] ${text}`);
    }
    if (data.method === 'Runtime.exceptionThrown') {
      console.error(`  [Chrome Exception]`, data.params.exceptionDetails);
    }
  };

  await new Promise(r => ws.onopen = r);

  function sendCommand(method, params = {}) {
    return new Promise((resolve) => {
      const id = messageId++;
      pendingRequests.set(id, resolve);
      ws.send(JSON.stringify({ id, method, params }));
    });
  }

  // Enable CDP domains
  await sendCommand('Page.enable');
  await sendCommand('Runtime.enable');
  await sendCommand('Performance.enable');

  console.log('[4] Waiting for Flutter Web & CanvasKit to finish initialization...');
  await new Promise(r => setTimeout(r, 6000));

  // Capture baseline screenshot
  console.log('[5] Capturing Baseline Screenshot (100% zoom)...');
  const baseline = await sendCommand('Page.captureScreenshot', { format: 'png' });
  const outDir = path.join(__dirname, '..', 'reports');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, 'chrome_zoom_100_baseline.png'), Buffer.from(baseline.data, 'base64'));

  // Test 1: Mouse Wheel Zoom with Ctrl
  console.log('[6] Testing Mouse Wheel Zoom: Dispatching Ctrl + Wheel Upward (zoom in)...');
  for (let i = 0; i < 4; i++) {
    await sendCommand('Input.dispatchMouseEvent', {
      type: 'mouseWheel',
      x: 700,
      y: 450,
      deltaX: 0,
      deltaY: -80,
      modifiers: 2, // Control modifier
    });
    await new Promise(r => setTimeout(r, 60));
  }
  await new Promise(r => setTimeout(r, 600)); // wait for lerp animation

  const zoomedIn = await sendCommand('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(path.join(outDir, 'chrome_zoom_mouse_wheel_zoomed.png'), Buffer.from(zoomedIn.data, 'base64'));
  console.log('  -> Captured screenshot after Ctrl + Mouse Wheel zoom');

  // Test 2: Normal Mouse Wheel (without Ctrl)
  console.log('[7] Testing Normal Mouse Wheel: Dispatching Wheel Downward WITHOUT Ctrl...');
  await sendCommand('Input.dispatchMouseEvent', {
    type: 'mouseWheel',
    x: 700,
    y: 450,
    deltaX: 0,
    deltaY: 120,
    modifiers: 0, // No modifiers
  });
  await new Promise(r => setTimeout(r, 400));

  // Test 3: Touchpad Precision Pinch Gesture Simulation (Chrome synthetic wheel events with ctrlKey)
  console.log('[8] Testing Touchpad Pinch Gesture: Sub-pixel high-frequency pinch events...');
  for (let i = 0; i < 6; i++) {
    await sendCommand('Input.dispatchMouseEvent', {
      type: 'mouseWheel',
      x: 750,
      y: 400,
      deltaX: 0,
      deltaY: -35,
      modifiers: 2, // Ctrl
    });
    await new Promise(r => setTimeout(r, 30));
  }
  await new Promise(r => setTimeout(r, 600));

  const touchpadZoomed = await sendCommand('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(path.join(outDir, 'chrome_zoom_touchpad_zoomed.png'), Buffer.from(touchpadZoomed.data, 'base64'));
  console.log('  -> Captured screenshot after Touchpad Pinch zoom');

  // Test 4: Keyboard Shortcuts (Ctrl + 0 to reset)
  console.log('[9] Testing Keyboard Shortcuts: Dispatching Ctrl + 0 (Reset Zoom)...');
  await sendCommand('Input.dispatchKeyEvent', {
    type: 'rawKeyDown',
    modifiers: 2,
    key: '0',
    code: 'Digit0',
    windowsVirtualKeyCode: 48,
  });
  await sendCommand('Input.dispatchKeyEvent', {
    type: 'keyUp',
    modifiers: 2,
    key: '0',
    code: 'Digit0',
    windowsVirtualKeyCode: 48,
  });
  await new Promise(r => setTimeout(r, 600));

  const resetScreenshot = await sendCommand('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(path.join(outDir, 'chrome_zoom_keyboard_reset.png'), Buffer.from(resetScreenshot.data, 'base64'));
  console.log('  -> Captured screenshot after Ctrl + 0 Reset');

  // Test 5: Keyboard Zoom In (Ctrl + =)
  console.log('[10] Testing Keyboard Shortcuts: Dispatching Ctrl + = (Zoom In)...');
  for (let k = 0; k < 2; k++) {
    await sendCommand('Input.dispatchKeyEvent', {
      type: 'rawKeyDown',
      modifiers: 2,
      key: '=',
      code: 'Equal',
      windowsVirtualKeyCode: 187,
    });
    await sendCommand('Input.dispatchKeyEvent', {
      type: 'keyUp',
      modifiers: 2,
      key: '=',
      code: 'Equal',
      windowsVirtualKeyCode: 187,
    });
    await new Promise(r => setTimeout(r, 100));
  }
  await new Promise(r => setTimeout(r, 500));

  // Performance metrics check
  console.log('[11] Inspecting Chrome Performance Metrics...');
  const perfMetrics = await sendCommand('Performance.getMetrics');
  const metricsMap = {};
  for (const m of perfMetrics.metrics) {
    metricsMap[m.name] = m.value;
  }
  console.log(`  JS Heap Used Size: ${(metricsMap.JSHeapUsedSize / 1024 / 1024).toFixed(2)} MB`);
  console.log(`  Layout Count: ${metricsMap.LayoutCount}`);
  console.log(`  Recalc Style Count: ${metricsMap.RecalcStyleCount}`);
  console.log(`  Frames: ${metricsMap.Frames}`);

  ws.close();
  chromeProcess.kill();
  server.close();
  console.log('[12] Real Chrome Verification Complete. Screenshots and performance metrics saved.');
}

runVerification().catch(err => {
  console.error('Verification failed:', err);
  process.exit(1);
});

