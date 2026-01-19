import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_theme.dart';

/// Clients list page - iOS HIG style with large title and grouped sections
class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final _searchController = TextEditingController();
  int _selectedSegment = 0; // 0=All, 1=Today, 2=Needs Attention

  // Mock data - will be replaced with actual data from BLoC
  final List<ClientData> _clients = [
    ClientData(
      id: '1',
      name: 'John Doe',
      email: 'john@email.com',
      goal: 'Build Muscle',
      lastWorkout: '2 days ago',
      workoutsThisWeek: 3,
      heightCm: 178,
      weightKg: 82,
      gymDays: [1, 3, 5], // Mon, Wed, Fri
      gymTime: const TimeOfDay(hour: 9, minute: 0),
    ),
    ClientData(
      id: '2',
      name: 'Sarah Miller',
      email: 'sarah@email.com',
      goal: 'Weight Loss',
      lastWorkout: 'Today',
      workoutsThisWeek: 4,
      heightCm: 165,
      weightKg: 68,
      gymDays: [1, 2, 4, 5], // Mon, Tue, Thu, Fri
      gymTime: const TimeOfDay(hour: 10, minute: 0),
    ),
    ClientData(
      id: '3',
      name: 'Mike Thompson',
      email: 'mike@email.com',
      goal: 'Strength',
      lastWorkout: 'Yesterday',
      workoutsThisWeek: 2,
      heightCm: 185,
      weightKg: 95,
      gymDays: [0, 2, 4], // Sun, Tue, Thu
      gymTime: const TimeOfDay(hour: 11, minute: 30),
    ),
    ClientData(
      id: '4',
      name: 'Emma Wilson',
      email: 'emma@email.com',
      goal: 'Toning',
      lastWorkout: '3 days ago',
      workoutsThisWeek: 2,
      heightCm: 162,
      weightKg: 58,
      gymDays: [1, 3], // Mon, Wed
      gymTime: const TimeOfDay(hour: 14, minute: 0),
    ),
    ClientData(
      id: '5',
      name: 'Chris Lee',
      email: 'chris@email.com',
      goal: 'Endurance',
      lastWorkout: 'Today',
      workoutsThisWeek: 5,
      heightCm: 172,
      weightKg: 70,
      gymDays: [1, 2, 3, 4, 5], // Mon-Fri
      gymTime: const TimeOfDay(hour: 16, minute: 0),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayClients = _clients.where((c) => c.isComingToday).length;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Large title
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            pinned: true,
            floating: true,
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Clients',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.37,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_clients.length} total',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: _showAddClientSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.add, color: AppColors.background, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search clients',
                placeholderStyle: TextStyle(color: AppColors.textTertiary),
                style: TextStyle(color: AppColors.textPrimary),
                backgroundColor: AppColors.surface,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Segmented control
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                onValueChanged: (value) {
                  if (value != null) setState(() => _selectedSegment = value);
                },
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('All', style: TextStyle(fontSize: 13)),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Today', style: TextStyle(fontSize: 13)),
                        if (todayClients > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$todayClients',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  2: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Needs Attention', style: TextStyle(fontSize: 13)),
                  ),
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Clients grouped list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final client = _filteredClients[index];
                  final isFirst = index == 0;
                  final isLast = index == _filteredClients.length - 1;
                  
                  return _ClientListTile(
                    client: client,
                    isFirst: isFirst,
                    isLast: isLast,
                    onTap: () => context.go(AppRoutes.clientDetailPath(client.id)),
                  );
                },
                childCount: _filteredClients.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  List<ClientData> get _filteredClients {
    var filtered = _clients;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) =>
          c.name.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query)).toList();
    }

    // Segment filter
    if (_selectedSegment == 1) {
      filtered = filtered.where((c) => c.isComingToday).toList();
    } else if (_selectedSegment == 2) {
      filtered = filtered.where((c) => c.workoutsThisWeek < 2).toList();
    }

    // Sort: today's clients first
    filtered.sort((a, b) {
      if (a.isComingToday && !b.isComingToday) return -1;
      if (!a.isComingToday && b.isComingToday) return 1;
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  void _showAddClientSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const _AddClientSheet(),
    );
  }
}

/// iOS-style client list tile with grouped appearance
class _ClientListTile extends StatelessWidget {
  final ClientData client;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _ClientListTile({
    required this.client,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: isFirst ? BorderSide.none : BorderSide(color: AppColors.surfaceLighter, width: 0.5),
          bottom: BorderSide(color: AppColors.surfaceLighter, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar - simple circle, no gradient
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      client.initials,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
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
                              client.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (client.isComingToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.goal,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${client.heightCm} cm • ${client.weightKg} kg',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BMI ${client.bmi.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Add Client Sheet - iOS-style form with grouped sections
class _AddClientSheet extends StatefulWidget {
  const _AddClientSheet();

  @override
  State<_AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<_AddClientSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _goalController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  TimeOfDay _gymTime = const TimeOfDay(hour: 9, minute: 0);
  final Set<int> _selectedDays = {};

  final _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _goalController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Client',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Basic Information section
                    _SectionHeader('Basic Information'),
                    const SizedBox(height: 8),
                    _GroupedSection(
                      children: [
                        _TextFieldTile(
                          controller: _nameController,
                          placeholder: 'Full Name',
                          icon: CupertinoIcons.person,
                        ),
                        _DividerTile(),
                        _TextFieldTile(
                          controller: _emailController,
                          placeholder: 'Email',
                          icon: CupertinoIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _DividerTile(),
                        _TextFieldTile(
                          controller: _phoneController,
                          placeholder: 'Phone (optional)',
                          icon: CupertinoIcons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _DividerTile(),
                        _TextFieldTile(
                          controller: _goalController,
                          placeholder: 'Goal',
                          icon: CupertinoIcons.flag,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Body Measurements section
                    _SectionHeader('Body Measurements'),
                    const SizedBox(height: 8),
                    _GroupedSection(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _TextFieldTile(
                                controller: _heightController,
                                placeholder: 'Height (cm)',
                                icon: CupertinoIcons.arrow_up_down,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Container(
                              width: 0.5,
                              height: 44,
                              color: AppColors.surfaceLighter,
                            ),
                            Expanded(
                              child: _TextFieldTile(
                                controller: _weightController,
                                placeholder: 'Weight (kg)',
                                icon: CupertinoIcons.gauge,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Gym Schedule section
                    _SectionHeader('Gym Schedule'),
                    const SizedBox(height: 8),
                    _GroupedSection(
                      children: [
                        _TimePickerTile(
                          time: _gymTime,
                          onTap: _selectGymTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Days selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Gym Days',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final isSelected = _selectedDays.contains(index);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDays.remove(index);
                                } else {
                                  _selectedDays.add(index);
                                }
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceLighter,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _weekDays[index],
                                  style: TextStyle(
                                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Add button
                    CupertinoButton.filled(
                      onPressed: _addClient,
                      child: const Text('Add Client'),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectGymTime() async {
    final time = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime(2024, 1, 1, _gymTime.hour, _gymTime.minute),
          onDateTimeChanged: (date) {
            setState(() {
              _gymTime = TimeOfDay(hour: date.hour, minute: date.minute);
            });
          },
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _addClient() {
    // TODO: Add client via BLoC
    Navigator.pop(context);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}

class _GroupedSection extends StatelessWidget {
  final List<Widget> children;

  const _GroupedSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _TextFieldTile extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final TextInputType? keyboardType;

  const _TextFieldTile({
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              placeholderStyle: TextStyle(color: AppColors.textTertiary),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
              keyboardType: keyboardType,
              decoration: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 48),
      height: 0.5,
      color: AppColors.surfaceLighter,
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerTile({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(CupertinoIcons.time, color: AppColors.textTertiary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Gym Time',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$hour:$minute $period',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right, color: AppColors.textTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Client data model
class ClientData {
  final String id;
  final String name;
  final String email;
  final String goal;
  final String lastWorkout;
  final int workoutsThisWeek;
  final double heightCm;
  final double weightKg;
  final List<int> gymDays; // 0=Sun, 1=Mon, etc.
  final TimeOfDay gymTime;

  ClientData({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.lastWorkout,
    required this.workoutsThisWeek,
    required this.heightCm,
    required this.weightKg,
    required this.gymDays,
    required this.gymTime,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  bool get isComingToday {
    final today = DateTime.now().weekday % 7; // Convert to 0=Sun format
    return gymDays.contains(today);
  }

  String get gymTimeFormatted {
    final hour = gymTime.hourOfPeriod == 0 ? 12 : gymTime.hourOfPeriod;
    final minute = gymTime.minute.toString().padLeft(2, '0');
    final period = gymTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  Color get bmiColor {
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25) return AppColors.secondary;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }
}
