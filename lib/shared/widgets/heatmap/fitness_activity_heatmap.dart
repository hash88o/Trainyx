import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

enum FitnessHeatmapView { weekly, monthly, yearly }

class FitnessActivityDay {
  final DateTime date;
  final int planned;
  final int completed;

  const FitnessActivityDay({
    required this.date,
    required this.planned,
    required this.completed,
  });

  int get missed => math.max(0, planned - completed);
}

class FitnessActivityHeatmap extends StatefulWidget {
  final String title;
  final String? subtitle;

  /// If provided, these are used as the data source (recommended).
  final List<FitnessActivityDay>? days;

  /// Temporary: while backend isn’t wired, we generate stable mock data per id.
  final String? seedKey;

  final FitnessHeatmapView initialView;

  const FitnessActivityHeatmap({
    super.key,
    this.days,
    this.seedKey,
    this.title = 'Activity',
    this.subtitle,
    this.initialView = FitnessHeatmapView.weekly,
  });

  @override
  State<FitnessActivityHeatmap> createState() => _FitnessActivityHeatmapState();
}

class _FitnessActivityHeatmapState extends State<FitnessActivityHeatmap> {
  late FitnessHeatmapView _view;

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _responsiveScale(context);
    final now = DateTime.now();
    final days = widget.days ?? _generateMockDays(now: now, seedKey: widget.seedKey ?? 'default');

    final weeks = _aggregateWeeks(days: days, now: now, count: 16);
    final months = _aggregateMonths(days: days, now: now, count: 12);
    final years = _aggregateYears(days: days, now: now, maxCount: 5);

    final summary = _summaryForView(view: _view, weeks: weeks, months: months, years: years);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 360 * scale),
              child: CupertinoSlidingSegmentedControl<FitnessHeatmapView>(
                groupValue: _view,
                onValueChanged: (value) {
                  if (value != null) setState(() => _view = value);
                },
                children: {
                  FitnessHeatmapView.weekly: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 12 * scale),
                    child: Text('Weekly', style: TextStyle(fontSize: 13 * scale)),
                  ),
                  FitnessHeatmapView.monthly: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 12 * scale),
                    child: Text('Monthly', style: TextStyle(fontSize: 13 * scale)),
                  ),
                  FitnessHeatmapView.yearly: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 12 * scale),
                    child: Text('Yearly', style: TextStyle(fontSize: 13 * scale)),
                  ),
                },
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          _MotivationRow(
            currentStreakWeeks: summary.currentStreakWeeks,
            bestStreakWeeks: summary.bestStreakWeeks,
            consistencyPct: summary.consistencyPct,
            scale: scale,
          ),
          SizedBox(height: 12 * scale),
          _PeriodBlocks(
            view: _view,
            weeks: weeks,
            months: months,
            years: years,
            onTapWeek: (w) => _showWeekDetails(context, w),
            onTapMonth: (m) => _showMonthDetails(context, m),
            onTapYear: (y) => _showYearDetails(context, y),
            scale: scale,
          ),
          SizedBox(height: 10 * scale),
          _Legend(view: _view, years: years, scale: scale),
        ],
      ),
    );
  }

  void _showWeekDetails(BuildContext context, FitnessWeekSummary week) {
    final title =
        '${DateFormat('MMM d').format(week.start)} \u2013 ${DateFormat('MMM d, y').format(week.end)}';
    _showDetailsSheet(
      context: context,
      title: title,
      lines: [
        _DetailLineData(label: 'Planned workouts', value: '${week.planned}', valueColor: AppColors.textPrimary),
        _DetailLineData(label: 'Completed workouts', value: '${week.completed}', valueColor: AppColors.primary),
        _DetailLineData(label: 'Missed workouts', value: '${week.missed}', valueColor: AppColors.error),
        _DetailLineData(
          label: 'Consistency',
          value: '${week.consistencyPct}%',
          valueColor: _consistencyColor(week.consistencyPct),
        ),
      ],
    );
  }

  void _showMonthDetails(BuildContext context, FitnessMonthSummary month) {
    final title = DateFormat('MMMM y').format(month.start);
    _showDetailsSheet(
      context: context,
      title: title,
      lines: [
        _DetailLineData(label: 'Total sessions', value: '${month.completed}', valueColor: AppColors.primary),
        _DetailLineData(
          label: 'Average per week',
          value: month.avgPerWeek.toStringAsFixed(1),
          valueColor: AppColors.textPrimary,
        ),
        _DetailLineData(
          label: 'Consistency',
          value: '${month.consistencyPct}%',
          valueColor: _consistencyColor(month.consistencyPct),
        ),
      ],
    );
  }

  void _showYearDetails(BuildContext context, FitnessYearSummary year) {
    final title = '${year.start.year}';
    _showDetailsSheet(
      context: context,
      title: title,
      lines: [
        _DetailLineData(label: 'Total workouts', value: '${year.completed}', valueColor: AppColors.primary),
        _DetailLineData(label: 'Best month', value: year.bestMonthLabel ?? '—', valueColor: AppColors.secondary),
        _DetailLineData(label: 'Worst month', value: year.worstMonthLabel ?? '—', valueColor: AppColors.warning),
      ],
    );
  }
}

class FitnessWeekSummary {
  final DateTime start; // Monday
  final DateTime end; // Sunday
  final int planned;
  final int completed;
  final int missed;
  final int consistencyPct;

  const FitnessWeekSummary({
    required this.start,
    required this.end,
    required this.planned,
    required this.completed,
    required this.missed,
    required this.consistencyPct,
  });
}

class FitnessMonthSummary {
  final DateTime start; // first day of month
  final DateTime end; // last day of month
  final int planned;
  final int completed;
  final int missed;
  final int consistencyPct;
  final double avgPerWeek;

  const FitnessMonthSummary({
    required this.start,
    required this.end,
    required this.planned,
    required this.completed,
    required this.missed,
    required this.consistencyPct,
    required this.avgPerWeek,
  });
}

class FitnessYearSummary {
  final DateTime start; // Jan 1
  final DateTime end; // Dec 31
  final int planned;
  final int completed;
  final int missed;
  final int consistencyPct;
  final String? bestMonthLabel;
  final String? worstMonthLabel;

  const FitnessYearSummary({
    required this.start,
    required this.end,
    required this.planned,
    required this.completed,
    required this.missed,
    required this.consistencyPct,
    required this.bestMonthLabel,
    required this.worstMonthLabel,
  });
}

class _MotivationSummary {
  final int currentStreakWeeks;
  final int bestStreakWeeks;
  final int consistencyPct;

  const _MotivationSummary({
    required this.currentStreakWeeks,
    required this.bestStreakWeeks,
    required this.consistencyPct,
  });
}

double _responsiveScale(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width <= 320) return 0.78;
  if (width <= 360) return 0.85;
  if (width <= 400) return 0.95;
  return 1.0;
}

_MotivationSummary _summaryForView({
  required FitnessHeatmapView view,
  required List<FitnessWeekSummary> weeks,
  required List<FitnessMonthSummary> months,
  required List<FitnessYearSummary> years,
}) {
  int current = 0;
  for (int i = weeks.length - 1; i >= 0; i--) {
    if (weeks[i].completed > 0) {
      current++;
    } else {
      break;
    }
  }

  int best = 0;
  int run = 0;
  for (final w in weeks) {
    if (w.completed > 0) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }

  int planned = 0;
  int completed = 0;
  switch (view) {
    case FitnessHeatmapView.weekly:
      for (final w in weeks) {
        planned += w.planned;
        completed += w.completed;
      }
    case FitnessHeatmapView.monthly:
      for (final m in months) {
        planned += m.planned;
        completed += m.completed;
      }
    case FitnessHeatmapView.yearly:
      for (final y in years) {
        planned += y.planned;
        completed += y.completed;
      }
  }
  final consistencyPct = planned == 0 ? 0 : ((completed / planned) * 100).round();

  return _MotivationSummary(
    currentStreakWeeks: current,
    bestStreakWeeks: best,
    consistencyPct: consistencyPct,
  );
}

List<FitnessActivityDay> _generateMockDays({
  required DateTime now,
  required String seedKey,
}) {
  final today = _dateOnly(now);
  int seed = 0;
  for (final unit in seedKey.codeUnits) {
    seed = (seed * 31 + unit) & 0x7fffffff;
  }
  final random = math.Random(seed);

  const daysBack = 18 * 31;
  final start = today.subtract(const Duration(days: daysBack));

  final out = <FitnessActivityDay>[];
  for (int i = 0; i <= daysBack; i++) {
    final date = start.add(Duration(days: i));
    final planned = random.nextDouble() < 0.55 ? 0 : (2 + random.nextInt(4)); // 0 or 2–5
    final completed = planned == 0 ? (random.nextDouble() < 0.1 ? 1 : 0) : random.nextInt(planned + 1);
    out.add(FitnessActivityDay(date: date, planned: planned, completed: completed));
  }
  return out;
}

List<FitnessWeekSummary> _aggregateWeeks({
  required List<FitnessActivityDay> days,
  required DateTime now,
  required int count,
}) {
  final today = _dateOnly(now);
  final end = _startOfWeekMonday(today).add(const Duration(days: 6));
  final start = end.subtract(Duration(days: (count * 7) - 1));

  final totals = <DateTime, _Totals>{};
  for (final d in days) {
    final date = _dateOnly(d.date);
    if (date.isBefore(start) || date.isAfter(end)) continue;
    final key = _startOfWeekMonday(date);
    totals[key] = (totals[key] ?? const _Totals.zero()).add(planned: d.planned, completed: d.completed);
  }

  final out = <FitnessWeekSummary>[];
  for (int i = 0; i < count; i++) {
    final monday = start.add(Duration(days: i * 7));
    final sunday = monday.add(const Duration(days: 6));
    final t = totals[monday] ?? const _Totals.zero();
    out.add(
      FitnessWeekSummary(
        start: monday,
        end: sunday,
        planned: t.planned,
        completed: t.completed,
        missed: math.max(0, t.planned - t.completed),
        consistencyPct: t.planned == 0 ? 0 : ((t.completed / t.planned) * 100).round(),
      ),
    );
  }
  return out;
}

List<FitnessMonthSummary> _aggregateMonths({
  required List<FitnessActivityDay> days,
  required DateTime now,
  required int count,
}) {
  final today = _dateOnly(now);
  final endMonthStart = DateTime(today.year, today.month, 1);

  final monthStarts = <DateTime>[];
  for (int i = count - 1; i >= 0; i--) {
    monthStarts.add(DateTime(endMonthStart.year, endMonthStart.month - i, 1));
  }
  final monthSet = monthStarts.toSet();

  final totals = <DateTime, _Totals>{};
  for (final d in days) {
    final date = _dateOnly(d.date);
    final key = DateTime(date.year, date.month, 1);
    if (!monthSet.contains(key)) continue;
    totals[key] = (totals[key] ?? const _Totals.zero()).add(planned: d.planned, completed: d.completed);
  }

  final out = <FitnessMonthSummary>[];
  for (final monthStart in monthStarts) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    final t = totals[monthStart] ?? const _Totals.zero();
    final weeksInMonth = ((monthEnd.difference(monthStart).inDays + 1) / 7).ceil();
    out.add(
      FitnessMonthSummary(
        start: monthStart,
        end: monthEnd,
        planned: t.planned,
        completed: t.completed,
        missed: math.max(0, t.planned - t.completed),
        consistencyPct: t.planned == 0 ? 0 : ((t.completed / t.planned) * 100).round(),
        avgPerWeek: weeksInMonth == 0 ? 0 : t.completed / weeksInMonth,
      ),
    );
  }
  return out;
}

List<FitnessYearSummary> _aggregateYears({
  required List<FitnessActivityDay> days,
  required DateTime now,
  required int maxCount,
}) {
  final today = _dateOnly(now);
  final currentYear = today.year;

  final yearsWithData = <int>{};
  for (final d in days) {
    if (d.planned > 0 || d.completed > 0) yearsWithData.add(d.date.year);
  }

  final visibleYears = <int>[];
  for (int y = currentYear; y >= currentYear - (maxCount - 1); y--) {
    if (yearsWithData.contains(y) || y == currentYear) visibleYears.add(y);
  }
  visibleYears.sort();

  final totals = <int, _Totals>{};
  final monthTotals = <int, Map<int, _Totals>>{};
  for (final d in days) {
    final y = d.date.year;
    if (!visibleYears.contains(y)) continue;
    totals[y] = (totals[y] ?? const _Totals.zero()).add(planned: d.planned, completed: d.completed);

    final byMonth = monthTotals[y] ?? <int, _Totals>{};
    byMonth[d.date.month] = (byMonth[d.date.month] ?? const _Totals.zero()).add(planned: d.planned, completed: d.completed);
    monthTotals[y] = byMonth;
  }

  final out = <FitnessYearSummary>[];
  for (final y in visibleYears) {
    final t = totals[y] ?? const _Totals.zero();
    final byMonth = monthTotals[y] ?? const <int, _Totals>{};

    String? best;
    String? worst;
    if (byMonth.isNotEmpty) {
      double bestScore = -1;
      double worstScore = 2;
      int? bestMonth;
      int? worstMonth;
      for (final entry in byMonth.entries) {
        final mt = entry.value;
        final score = mt.planned == 0 ? (mt.completed == 0 ? 0 : 1) : (mt.completed / mt.planned);
        if (score > bestScore) {
          bestScore = score.toDouble();
          bestMonth = entry.key;
        }
        if (score < worstScore) {
          worstScore = score.toDouble();
          worstMonth = entry.key;
        }
      }
      if (bestMonth != null) best = DateFormat('MMM').format(DateTime(y, bestMonth, 1));
      if (worstMonth != null) worst = DateFormat('MMM').format(DateTime(y, worstMonth, 1));
    }

    out.add(
      FitnessYearSummary(
        start: DateTime(y, 1, 1),
        end: DateTime(y, 12, 31),
        planned: t.planned,
        completed: t.completed,
        missed: math.max(0, t.planned - t.completed),
        consistencyPct: t.planned == 0 ? 0 : ((t.completed / t.planned) * 100).round(),
        bestMonthLabel: best,
        worstMonthLabel: worst,
      ),
    );
  }
  return out;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _startOfWeekMonday(DateTime date) {
  final d = _dateOnly(date);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

Color _consistencyColor(int pct) {
  if (pct >= 70) return AppColors.secondary;
  if (pct >= 40) return AppColors.warning;
  return AppColors.error;
}

class _Totals {
  final int planned;
  final int completed;
  const _Totals({required this.planned, required this.completed});
  const _Totals.zero() : planned = 0, completed = 0;

  _Totals add({required int planned, required int completed}) {
    return _Totals(planned: this.planned + planned, completed: this.completed + completed);
  }
}

class _PeriodBlocks extends StatelessWidget {
  final FitnessHeatmapView view;
  final List<FitnessWeekSummary> weeks;
  final List<FitnessMonthSummary> months;
  final List<FitnessYearSummary> years;
  final ValueChanged<FitnessWeekSummary> onTapWeek;
  final ValueChanged<FitnessMonthSummary> onTapMonth;
  final ValueChanged<FitnessYearSummary> onTapYear;
  final double scale;

  const _PeriodBlocks({
    required this.view,
    required this.weeks,
    required this.months,
    required this.years,
    required this.onTapWeek,
    required this.onTapMonth,
    required this.onTapYear,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case FitnessHeatmapView.weekly:
        return _WeeklyBlocks(weeks: weeks, onTap: onTapWeek, scale: scale);
      case FitnessHeatmapView.monthly:
        return _MonthlyBlocks(months: months, onTap: onTapMonth, scale: scale);
      case FitnessHeatmapView.yearly:
        return _YearlyBlocks(years: years, onTap: onTapYear, scale: scale);
    }
  }
}

class _WeeklyBlocks extends StatelessWidget {
  final List<FitnessWeekSummary> weeks;
  final ValueChanged<FitnessWeekSummary> onTap;
  final double scale;

  const _WeeklyBlocks({
    required this.weeks,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final block = 42.0 * scale;
    final gap = 10.0 * scale;
    final showMonthLabels = MediaQuery.of(context).size.width >= 340;

    final monthLabels = <int, String>{};
    int lastMonth = -1;
    for (int i = 0; i < weeks.length; i++) {
      final m = weeks[i].start.month;
      if (m != lastMonth) {
        monthLabels[i] = DateFormat('MMM').format(weeks[i].start);
        lastMonth = m;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: block + (showMonthLabels ? 26 * scale : 0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weeks.length,
            separatorBuilder: (context, index) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final w = weeks[index];
              final monthLabel = showMonthLabels ? monthLabels[index] : null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeatBlock(
                    color: _weeklyColor(w),
                    size: block,
                    onTap: () => onTap(w),
                  ),
                  if (showMonthLabels) ...[
                    SizedBox(height: 6 * scale),
                    if (monthLabel != null)
                      Text(
                        monthLabel,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      SizedBox(height: 11 * scale),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color _weeklyColor(FitnessWeekSummary week) {
    if (week.planned > 0 && week.completed == 0) return AppColors.error.withValues(alpha: 0.7);
    if (week.completed == 0) return AppColors.surfaceLight;
    if (week.completed <= 2) return AppColors.primary.withValues(alpha: 0.35);
    if (week.completed <= 4) return AppColors.primary.withValues(alpha: 0.6);
    return AppColors.primary;
  }
}

class _MonthlyBlocks extends StatelessWidget {
  final List<FitnessMonthSummary> months;
  final ValueChanged<FitnessMonthSummary> onTap;
  final double scale;

  const _MonthlyBlocks({
    required this.months,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final block = 46.0 * scale;
    return SizedBox(
      height: block + 22 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        separatorBuilder: (context, index) => SizedBox(width: 10 * scale),
        itemBuilder: (context, index) {
          final m = months[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeatBlock(
                color: _monthlyColor(m),
                size: block,
                onTap: () => onTap(m),
              ),
              SizedBox(height: 6 * scale),
              Text(
                DateFormat('MMM').format(m.start),
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _monthlyColor(FitnessMonthSummary month) {
    if (month.planned == 0 && month.completed == 0) return AppColors.surfaceLight;
    if (month.consistencyPct < 40) return AppColors.error.withValues(alpha: 0.75);
    if (month.consistencyPct < 70) return AppColors.warning.withValues(alpha: 0.85);
    return AppColors.secondary.withValues(alpha: 0.85);
  }
}

class _YearlyBlocks extends StatelessWidget {
  final List<FitnessYearSummary> years;
  final ValueChanged<FitnessYearSummary> onTap;
  final double scale;

  const _YearlyBlocks({
    required this.years,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final block = 54.0 * scale;
    final maxCompleted = years.fold<int>(0, (m, y) => math.max(m, y.completed));

    return SizedBox(
      height: block + 22 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        separatorBuilder: (context, index) => SizedBox(width: 12 * scale),
        itemBuilder: (context, index) {
          final y = years[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeatBlock(
                color: _yearlyColor(year: y, maxCompleted: maxCompleted),
                size: block,
                onTap: () => onTap(y),
              ),
              SizedBox(height: 6 * scale),
              Text(
                '${y.start.year}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _yearlyColor({required FitnessYearSummary year, required int maxCompleted}) {
    if (year.completed == 0) return AppColors.surfaceLight;
    if (maxCompleted <= 0) return AppColors.primary.withValues(alpha: 0.35);
    final ratio = year.completed / maxCompleted;
    if (ratio <= 0.34) return AppColors.primary.withValues(alpha: 0.35);
    if (ratio <= 0.67) return AppColors.primary.withValues(alpha: 0.6);
    return AppColors.primary;
  }
}

class _HeatBlock extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _HeatBlock({
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size * 0.33),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.33),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final FitnessHeatmapView view;
  final List<FitnessYearSummary> years;
  final double scale;

  const _Legend({required this.view, required this.years, required this.scale});

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case FitnessHeatmapView.weekly:
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10 * scale,
          runSpacing: 6 * scale,
          children: [
            _LegendChip(color: AppColors.primary.withValues(alpha: 0.35), label: 'Low (1–2)', scale: scale),
            _LegendChip(color: AppColors.primary.withValues(alpha: 0.6), label: 'Medium (3–4)', scale: scale),
            _LegendChip(color: AppColors.primary, label: 'High (5+)', scale: scale),
            _LegendChip(color: AppColors.error.withValues(alpha: 0.7), label: 'Missed', scale: scale),
          ],
        );
      case FitnessHeatmapView.monthly:
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10 * scale,
          runSpacing: 6 * scale,
          children: [
            _LegendChip(color: AppColors.error.withValues(alpha: 0.75), label: 'Low (<40%)', scale: scale),
            _LegendChip(color: AppColors.warning.withValues(alpha: 0.85), label: 'Medium (40–70%)', scale: scale),
            _LegendChip(color: AppColors.secondary.withValues(alpha: 0.85), label: 'High (70%+)', scale: scale),
          ],
        );
      case FitnessHeatmapView.yearly:
        final maxCompleted = years.fold<int>(0, (m, y) => math.max(m, y.completed));
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10 * scale,
          runSpacing: 6 * scale,
          children: [
            _LegendChip(color: AppColors.surfaceLight, label: 'No activity', scale: scale),
            _LegendChip(
              color: maxCompleted <= 0 ? AppColors.primary.withValues(alpha: 0.35) : AppColors.primary.withValues(alpha: 0.35),
              label: 'Low',
              scale: scale,
            ),
            _LegendChip(color: AppColors.primary.withValues(alpha: 0.6), label: 'Medium', scale: scale),
            _LegendChip(color: AppColors.primary, label: 'High', scale: scale),
          ],
        );
    }
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final double scale;

  const _LegendChip({required this.color, required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14 * scale,
          height: 14 * scale,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4 * scale),
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MotivationRow extends StatelessWidget {
  final int currentStreakWeeks;
  final int bestStreakWeeks;
  final int consistencyPct;
  final double scale;

  const _MotivationRow({
    required this.currentStreakWeeks,
    required this.bestStreakWeeks,
    required this.consistencyPct,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 18 * scale,
          runSpacing: 10 * scale,
          children: [
            _MiniStat(label: 'Current Streak', value: '$currentStreakWeeks wk', scale: scale),
            _MiniStat(label: 'Best Streak', value: '$bestStreakWeeks wk', scale: scale),
            _MiniStat(label: 'Consistency', value: '$consistencyPct%', scale: scale),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final double scale;
  const _MiniStat({required this.label, required this.value, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DetailLineData {
  final String label;
  final String value;
  final Color valueColor;
  const _DetailLineData({required this.label, required this.value, required this.valueColor});
}

void _showDetailsSheet({
  required BuildContext context,
  required String title,
  required List<_DetailLineData> lines,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceLighter, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < lines.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _DetailLine(
                    label: lines[i].label,
                    value: lines[i].value,
                    valueColor: lines[i].valueColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailLine({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}


