import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/enums/log_category.dart';
import '../../../../shared/domain/enums/log_severity.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../domain/models/activity_log_entry.dart';
import '../state/activity_logs_state.dart';
import '../viewmodels/activity_logs_viewmodel.dart';

class ActivityLogsScreen extends StatefulWidget {
  final ActivityLogsViewModel viewModel;
  final VoidCallback onBack;

  const ActivityLogsScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is ActivityLogsInitial) {
        widget.viewModel.loadLogs();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;

        return switch (state) {
          ActivityLogsInitial() || ActivityLogsLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          ActivityLogsError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('LOGS ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadLogs(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          ActivityLogsLoaded() => LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= ScreenBreakpoints.tabletMax;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : 720,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppPageHeader(
                            pageTitle: 'Activity & Event Logs',
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Telemetry Events, Fault History & Operation Audit',
                            style: AppTypography.subtitle,
                          ),
                          const SizedBox(height: 16),
                          _buildSearchAndFilters(state),
                          const SizedBox(height: 16),
                          _buildLogsList(state),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        };
      },
    );
  }

  Widget _buildSearchAndFilters(ActivityLogsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (val) => widget.viewModel.setSearchQuery(val),
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search events by keyword, source or code...',
              hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.secondaryText, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        widget.viewModel.setSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.raisedSurface),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.raisedSurface),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Category Filters
          Text('Category', style: AppTypography.fieldLabel),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All',
                  state.selectedCategory == null,
                  () => widget.viewModel.selectCategory(null),
                ),
                ...LogCategory.values.map(
                  (c) => _buildFilterChip(
                    c.displayLabel,
                    state.selectedCategory == c,
                    () => widget.viewModel.selectCategory(c),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Severity Filters & Export
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildSeverityChip(
                      'All',
                      state.selectedSeverity == null,
                      () => widget.viewModel.selectSeverity(null),
                    ),
                    ...LogSeverity.values.map(
                      (s) => _buildSeverityChip(
                        s.displayLabel,
                        state.selectedSeverity == s,
                        () => widget.viewModel.selectSeverity(s),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: AppColors.gold, size: 20),
                tooltip: 'Export Logs',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final count = state.allLogs.length;
                  await widget.viewModel.exportLogs();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Exported $count events (Simulated export)'),
                      backgroundColor: AppColors.raisedSurface,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : AppColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.raisedSurface,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.black : AppColors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.raisedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.white : AppColors.raisedSurface,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogsList(ActivityLogsLoaded state) {
    if (state.filteredLogs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.raisedSurface, width: 1),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.secondaryText, size: 36),
            const SizedBox(height: 10),
            Text('No events match the active filter criteria', style: AppTypography.cardTitle),
            const SizedBox(height: 4),
            Text('Try clearing the search term or category filters', style: AppTypography.caption),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.filteredLogs.length,
        separatorBuilder: (context, index) => const Divider(color: AppColors.raisedSurface, height: 1),
        itemBuilder: (context, index) {
          final log = state.filteredLogs[index];
          return _buildLogTile(log);
        },
      ),
    );
  }

  Widget _buildLogTile(ActivityLogEntry log) {
    Color severityColor = AppColors.secondaryText;
    switch (log.severity) {
      case LogSeverity.info:
        severityColor = AppColors.secondaryText;
        break;
      case LogSeverity.warning:
        severityColor = AppColors.gold;
        break;
      case LogSeverity.error:
        severityColor = AppColors.burgundy;
        break;
    }

    return InkWell(
      onTap: () => _showEventDetailsDialog(log),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.timestamp,
              style: AppTypography.telemetryBase.copyWith(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.title,
                          style: AppTypography.cardTitle.copyWith(fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.raisedSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.category.displayLabel,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.description,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetailsDialog(ActivityLogEntry log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.raisedSurface, width: 1),
          ),
          title: Text(log.title, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogRow('Event ID', log.id),
              _buildDialogRow('Timestamp', log.timestamp),
              _buildDialogRow('Category', log.category.displayLabel),
              _buildDialogRow('Severity', log.severity.displayLabel),
              _buildDialogRow('Source', log.source),
              if (log.errorCode != null) _buildDialogRow('Error Code', log.errorCode!),
              const SizedBox(height: 10),
              const Divider(color: AppColors.raisedSurface),
              const SizedBox(height: 6),
              Text('Description:', style: AppTypography.fieldLabel),
              const SizedBox(height: 4),
              Text(log.description, style: AppTypography.interfaceBase.copyWith(fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.secondaryText)),
          Text(value, style: AppTypography.telemetryBase.copyWith(color: AppColors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
