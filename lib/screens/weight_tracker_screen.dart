import 'package:flutter/material.dart';
import '../controllers/weight_tracker_controller.dart';
import '../models/bmi_category.dart';
import '../services/date_format_service.dart';
import '../services/measurement_service.dart';
import '../widgets/history_metric.dart';
import '../widgets/measurement_entry_field.dart';
import '../widgets/weight_progress_chart_card.dart';
import '../widgets/weight_summary_card.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final DateFormatService _dateFormatService = const DateFormatService();
  final MeasurementService _measurementService = const MeasurementService();
  final controller = WeightTrackerController();
  bool _isConfirmingEntry = false;

  @override
  void initState() {
    super.initState();
    controller.weightController.addListener(_clearEntryConfirmation);
    controller.heightController.addListener(_clearEntryConfirmation);
    Future.wait([
      controller.loadEntries(),
      controller.loadProfileHeight(),
    ]).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartWeights = controller.chartEntries.map((e) => e.weight);
    final chartMinY = chartWeights.isEmpty
        ? 0.0
        : (chartWeights.reduce((a, b) => a < b ? a : b) / 10).floor() * 10.0;
    final chartMaxY = chartWeights.isEmpty
        ? 10.0
        : (chartWeights.reduce((a, b) => a > b ? a : b) / 10).ceil() * 10.0;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Entry',
        backgroundColor: const Color(0xFF35E0A1),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _showAddEntrySheet(context, isDark),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
          children: [
            Row(
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF111212)
                        : const Color(0xFFEAF4F0),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight & BMI Tracker',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track your weight & BMI over time',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'History',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF111212)
                        : const Color(0xFFEAF4F0),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _showHistory(context, isDark),
                  icon: const Icon(Icons.history_rounded),
                ),
              ],
            ),
            const SizedBox(height: 26),
            WeightSummaryCard(
              latestDate: controller.latestDate,
              weightText:
                  controller.latestEntry?.weight.toStringAsFixed(2) ?? '--',
              bmiText: controller.latestEntry?.bmi.toStringAsFixed(1) ?? '--',
              bmiStatus: controller.bmiStatus,
              bmiStatusBackgroundColor: _bmiStatusBackgroundColor(
                controller.bmiCategory,
                isDark,
              ),
              bmiStatusTextColor: _bmiStatusTextColor(
                controller.bmiCategory,
                isDark,
              ),
            ),
            const SizedBox(height: 10),
            WeightProgressChartCard(
              hasEntries: controller.entries.isNotEmpty,
              chartDates: controller.chartDates,
              chartSpots: controller.chartSpots,
              chartMinY: chartMinY,
              chartMaxY: chartMaxY,
              isCurved: controller.chartEntries.length > 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.weightController.removeListener(_clearEntryConfirmation);
    controller.heightController.removeListener(_clearEntryConfirmation);
    controller.dispose();
    super.dispose();
  }

  void _clearEntryConfirmation() {
    if (!_isConfirmingEntry || !mounted) return;

    setState(() {
      _isConfirmingEntry = false;
    });
  }

  Color _bmiStatusBackgroundColor(BmiCategory category, bool isDark) {
    return category.backgroundColor(isDark: isDark);
  }

  Color _bmiStatusTextColor(BmiCategory category, bool isDark) {
    return category.foregroundColor(isDark: isDark);
  }

  void _showAddEntrySheet(BuildContext context, bool isDark) {
    _isConfirmingEntry = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF050606) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);

        return StatefulBuilder(
          builder: (context, sheetSetState) {
            void refreshSheet() => sheetSetState(() {});
            void closeSheet() {
              if (sheetNavigator.canPop()) sheetNavigator.pop();
            }

            void clearConfirmation() {
              if (!_isConfirmingEntry) return;

              setState(() {
                _isConfirmingEntry = false;
              });
              refreshSheet();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add New Entry',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: MeasurementEntryField(
                            controller: controller.weightController,
                            label: 'Weight (kg)',
                            hintText: 'e.g. 72.50',
                            isDark: isDark,
                            onChanged: clearConfirmation,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: MeasurementEntryField(
                            controller: controller.heightController,
                            label: 'Height (cm)',
                            hintText: 'e.g. 180',
                            isDark: isDark,
                            onChanged: clearConfirmation,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_isConfirmingEntry) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF11241E)
                              : const Color(0xFFE7FBF2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF35E0A1)),
                        ),
                        child: Text(
                          _entryConfirmationText(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _handleEntryButtonPressed(
                            refreshSheet: refreshSheet,
                            closeSheet: closeSheet,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF35E0A1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          _isConfirmingEntry ? 'Confirm Entry' : 'Save Entry',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _hasValidEntryInput(String value) {
    return _measurementService.hasValidMeasurementInput(value);
  }

  String _entryConfirmationText() {
    final latestEntry = controller.latestEntry;
    final weightText = controller.weightController.text.trim();
    final heightText = controller.heightController.text.trim();
    final weight = double.tryParse(weightText);
    final height = double.tryParse(heightText);

    final changedValues = <String>[];

    if (latestEntry == null || weight == null || weight != latestEntry.weight) {
      changedValues.add('Weight: $weightText kg');
    }

    if (latestEntry == null ||
        height == null ||
        height != latestEntry.heightCentimeters) {
      changedValues.add('Height: $heightText cm');
    }

    if (changedValues.isEmpty) {
      changedValues.add('Weight: $weightText kg');
      changedValues.add('Height: $heightText cm');
    }

    return 'Confirm ${changedValues.join(' | ')}';
  }

  Future<void> _handleEntryButtonPressed({
    VoidCallback? refreshSheet,
    VoidCallback? closeSheet,
  }) async {
    final weight = controller.weightController.text.trim();
    final height = controller.heightController.text.trim();

    if (!_hasValidEntryInput(weight) || !_hasValidEntryInput(height)) {
      setState(() {
        _isConfirmingEntry = false;
      });
      refreshSheet?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter up to 3 digits with up to 2 decimal places.'),
        ),
      );
      return;
    }

    if (!_isConfirmingEntry) {
      setState(() {
        _isConfirmingEntry = true;
      });
      refreshSheet?.call();
      return;
    }

    await controller.saveEntry();
    if (!mounted) return;

    setState(() {
      _isConfirmingEntry = false;
    });
    refreshSheet?.call();
    closeSheet?.call();
  }

  void _showHistory(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF111212) : Colors.white;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;
    final messenger = ScaffoldMessenger.of(context);
    var isEditingLatest = false;
    var isSavingEdit = false;
    TextEditingController? editWeightController;
    TextEditingController? editHeightController;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, historySetState) {
            final entries = controller.entries.reversed.toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Change History',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Expanded(
                      child: entries.isEmpty
                          ? Center(
                              child: Text(
                                'No saved changes yet',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: entries.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                final canModify = index == 0;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF181A1A)
                                        : const Color(0xFFF6FAF8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            color: Color(0xFF35E0A1),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _formatHistoryDate(entry.date),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (canModify) ...[
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFF13C88B,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                              onPressed: () => historySetState(() {
                                                isEditingLatest = true;
                                                editWeightController =
                                                    TextEditingController(
                                                      text: _measurementService
                                                          .trimTrailingZeros(
                                                            entry.weight,
                                                          ),
                                                    );
                                                editHeightController =
                                                    TextEditingController(
                                                      text: _measurementService
                                                          .trimTrailingZeros(
                                                            entry
                                                                .heightCentimeters,
                                                          ),
                                                    );
                                              }),
                                              icon: const Icon(
                                                Icons.edit_rounded,
                                                size: 16,
                                              ),
                                              label: const Text('Modify'),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            _formatHistoryTime(entry.date),
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      if (canModify && isEditingLatest)
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MeasurementEntryField(
                                                    controller:
                                                        editWeightController!,
                                                    label: 'Weight (kg)',
                                                    hintText: 'e.g. 72.50',
                                                    isDark: isDark,
                                                    onChanged: () {},
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: MeasurementEntryField(
                                                    controller:
                                                        editHeightController!,
                                                    label: 'Height (cm)',
                                                    hintText: 'e.g. 180',
                                                    isDark: isDark,
                                                    onChanged: () {},
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 14),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: isSavingEdit
                                                        ? null
                                                        : () => historySetState(() {
                                                            isEditingLatest =
                                                                false;
                                                            editWeightController =
                                                                null;
                                                            editHeightController =
                                                                null;
                                                          }),
                                                    child: const Text('Cancel'),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: isSavingEdit
                                                        ? null
                                                        : () async {
                                                            final weight =
                                                                editWeightController!
                                                                    .text
                                                                    .trim();
                                                            final height =
                                                                editHeightController!
                                                                    .text
                                                                    .trim();

                                                            if (!_hasValidEntryInput(
                                                                  weight,
                                                                ) ||
                                                                !_hasValidEntryInput(
                                                                  height,
                                                                )) {
                                                              messenger.showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Enter up to 3 digits with up to 2 decimal places.',
                                                                  ),
                                                                ),
                                                              );
                                                              return;
                                                            }

                                                            historySetState(
                                                              () =>
                                                                  isSavingEdit =
                                                                      true,
                                                            );
                                                            final wasUpdated =
                                                                await controller
                                                                    .updateLatestEntry(
                                                                      entryId:
                                                                          entry
                                                                              .id,
                                                                      weightText:
                                                                          weight,
                                                                      heightText:
                                                                          height,
                                                                    );
                                                            if (!mounted) {
                                                              return;
                                                            }

                                                            if (!wasUpdated) {
                                                              historySetState(
                                                                () =>
                                                                    isSavingEdit =
                                                                        false,
                                                              );
                                                              messenger.showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Only the latest entry can be modified.',
                                                                  ),
                                                                ),
                                                              );
                                                              return;
                                                            }

                                                            editWeightController =
                                                                null;
                                                            editHeightController =
                                                                null;

                                                            setState(() {});
                                                            historySetState(() {
                                                              isSavingEdit =
                                                                  false;
                                                              isEditingLatest =
                                                                  false;
                                                            });
                                                          },
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                0xFF35E0A1,
                                                              ),
                                                          foregroundColor:
                                                              Colors.black,
                                                        ),
                                                    child: Text(
                                                      isSavingEdit
                                                          ? 'Saving...'
                                                          : 'Save',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      else
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            HistoryMetric(
                                              icon:
                                                  Icons.monitor_weight_outlined,
                                              label: 'Weight',
                                              value:
                                                  '${entry.weight.toStringAsFixed(2)} kg',
                                              isDark: isDark,
                                            ),
                                            HistoryMetric(
                                              icon: Icons.height_rounded,
                                              label: 'Height',
                                              value:
                                                  '${entry.heightCentimeters.toStringAsFixed(0)} cm',
                                              isDark: isDark,
                                            ),
                                            HistoryMetric(
                                              icon:
                                                  Icons.favorite_border_rounded,
                                              label: 'BMI',
                                              value: entry.bmi.toStringAsFixed(
                                                1,
                                              ),
                                              isDark: isDark,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      editWeightController?.dispose();
      editHeightController?.dispose();
    });
  }

  String _formatHistoryDate(DateTime date) {
    return _dateFormatService.shortMonthDate(date);
  }

  String _formatHistoryTime(DateTime date) {
    return _dateFormatService.clockTime(date);
  }
}
