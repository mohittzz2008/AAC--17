import 'package:flutter/material.dart';
import '../../domain/models/hardware_inventory_item.dart';
import 'hardware_inventory_card.dart';

/// 2x2 grid presenting the four key hardware components.
class HardwareOverviewGrid extends StatelessWidget {
  final List<HardwareInventoryItem> items;

  const HardwareOverviewGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.length < 4) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: HardwareInventoryCard(item: items[0])),
            const SizedBox(width: 12),
            Expanded(child: HardwareInventoryCard(item: items[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: HardwareInventoryCard(item: items[2])),
            const SizedBox(width: 12),
            Expanded(child: HardwareInventoryCard(item: items[3])),
          ],
        ),
      ],
    );
  }
}

