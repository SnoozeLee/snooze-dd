import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 底部弹出的滚轮拨盘时长选择器
class DurationPickerSheet extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onDurationSelected;

  const DurationPickerSheet({
    super.key,
    required this.initialMinutes,
    required this.onDurationSelected,
  });

  static Future<int?> show(
    BuildContext context, {
    required int initialMinutes,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DurationPickerSheet(
        initialMinutes: initialMinutes,
        onDurationSelected: (minutes) => Navigator.of(ctx).pop(minutes),
      ),
    );
  }

  @override
  State<DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<DurationPickerSheet> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  late int _selectedHours;
  late int _selectedMinutes;

  final List<int> _quickPresets = [15, 25, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final clamped = widget.initialMinutes.clamp(1, 180);
    _selectedHours = clamped ~/ 60;
    _selectedMinutes = clamped % 60;

    _hourController = FixedExtentScrollController(initialItem: _selectedHours);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinutes);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int get _totalMinutes => _selectedHours * 60 + _selectedMinutes;

  void _applyQuickPreset(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    setState(() {
      _selectedHours = h;
      _selectedMinutes = m;
    });
    _hourController.animateToItem(
      h,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _minuteController.animateToItem(
      m,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _totalMinutes >= 1 && _totalMinutes <= 180;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部拖拽手柄条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                Text(
                  '设置总时长',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton(
                  onPressed: isValid
                      ? () => widget.onDurationSelected(_totalMinutes)
                      : null,
                  child: const Text('完成'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 常用快捷预设按钮组
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickPresets.map((mins) {
                  final isSelected = _totalMinutes == mins;
                  final label = mins >= 60 && mins % 60 == 0
                      ? '${mins ~/ 60} 小时'
                      : '$mins 分钟';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(label),
                      onSelected: (_) => _applyQuickPreset(mins),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 滚轮选择器（小时 / 分钟）
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  // 小时轮盘 (0 ~ 3 小时)
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _hourController,
                      itemExtent: 44,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHours = index;
                        });
                      },
                      children: List.generate(4, (index) {
                        return Center(
                          child: Text(
                            '$index 小时',
                            style: theme.textTheme.titleMedium,
                          ),
                        );
                      }),
                    ),
                  ),
                  // 分钟轮盘 (0 ~ 59 分钟)
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _minuteController,
                      itemExtent: 44,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinutes = index;
                        });
                      },
                      children: List.generate(60, (index) {
                        return Center(
                          child: Text(
                            '$index 分钟',
                            style: theme.textTheme.titleMedium,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '时长必须在 1 分钟至 180 分钟之间',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
