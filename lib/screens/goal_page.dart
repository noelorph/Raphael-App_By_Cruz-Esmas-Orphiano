import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';

class GoalsPage extends StatefulWidget {
  final ValueNotifier<List<GoalModel>> goalsOverviewNotifier;

  const GoalsPage({super.key, required this.goalsOverviewNotifier});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  static const Color _accentColor = Color(0xFF35E8AE);

  final GoalService _goalService = GoalService();
  final Map<String, bool> _pendingGoalCompletion = {};
  late final Stream<List<GoalModel>> _goalsStream;
  List<GoalModel> _visibleGoals = const [];

  void _publishGoalsOverview() {
    widget.goalsOverviewNotifier.value = List.unmodifiable(_visibleGoals);
  }

  @override
  void initState() {
    super.initState();
    _goalsStream = _goalService.watchGoals();
  }

  Future<void> _saveGoal({
    GoalModel? goal,
    required String title,
    required String timeframe,
  }) async {
    await _goalService.saveGoal(
      goalId: goal?.id,
      title: title,
      timeframe: timeframe,
    );
  }

  Future<void> _deleteGoal(GoalModel goal) async {
    await _goalService.deleteGoal(goal.id);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Goal deleted')));
  }

  Future<void> _toggleGoalCompletion(GoalModel goal, bool? completed) async {
    if (completed == null) return;
    final previousGoals = _visibleGoals;

    setState(() {
      _pendingGoalCompletion[goal.id] = completed;
      _visibleGoals = _visibleGoals.map((visibleGoal) {
        if (visibleGoal.id != goal.id) return visibleGoal;

        return GoalModel(
          id: visibleGoal.id,
          title: visibleGoal.title,
          timeframe: visibleGoal.timeframe,
          completed: completed,
          createdAt: visibleGoal.createdAt,
          updatedAt: visibleGoal.updatedAt,
        );
      }).toList();
    });
    _publishGoalsOverview();

    try {
      await _goalService.toggleGoalCompletion(goal.id, completed);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingGoalCompletion.remove(goal.id);
        _visibleGoals = previousGoals;
      });
      _publishGoalsOverview();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update goal: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List<GoalModel> _applyPendingGoalCompletion(List<GoalModel> goals) {
    final confirmedGoalIds = <String>[];
    final nextGoals = goals.map((goal) {
      final pendingCompleted = _pendingGoalCompletion[goal.id];

      if (pendingCompleted == null) return goal;

      if (goal.completed == pendingCompleted) {
        confirmedGoalIds.add(goal.id);
        return goal;
      }

      return GoalModel(
        id: goal.id,
        title: goal.title,
        timeframe: goal.timeframe,
        completed: pendingCompleted,
        createdAt: goal.createdAt,
        updatedAt: goal.updatedAt,
      );
    }).toList();

    for (final goalId in confirmedGoalIds) {
      _pendingGoalCompletion.remove(goalId);
    }

    _visibleGoals = nextGoals;
    _publishGoalsOverview();
    return nextGoals;
  }

  void _showGoalDialog({GoalModel? goal}) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final timeframeController = TextEditingController(
      text: goal?.timeframe ?? '',
    );
    final isEditing = goal != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Goal' : 'Add Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Goal',
                  hintText: 'Enter your goal',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeframeController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Timeframe',
                  hintText: 'Daily, weekly, or a target date',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final timeframe = timeframeController.text.trim();

                if (title.isEmpty) return;

                try {
                  await _saveGoal(
                    goal: goal,
                    title: title,
                    timeframe: timeframe.isEmpty ? 'Anytime' : timeframe,
                  );

                  if (context.mounted) Navigator.pop(context);
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unable to save goal: $error'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      timeframeController.dispose();
    });
  }

  Future<void> _confirmDelete(GoalModel goal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Text('Delete "${goal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteGoal(goal);
    }
  }

  Widget _buildGoalRow(GoalModel goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: goal.completed
            ? Colors.transparent
            : isDark
            ? const Color(0xFF242424)
            : const Color(0xFFF2F5F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 28,
        contentPadding: const EdgeInsets.only(left: 8, right: 4),
        leading: Transform.scale(
          scale: 1.05,
          child: Checkbox(
            value: goal.completed,
            shape: const CircleBorder(),
            side: BorderSide(
              color: goal.completed ? _accentColor : mutedColor,
              width: 2,
            ),
            activeColor: _accentColor,
            checkColor: isDark ? Colors.black : Colors.white,
            onChanged: _pendingGoalCompletion.containsKey(goal.id)
                ? null
                : (value) => _toggleGoalCompletion(goal, value),
          ),
        ),
        title: Text(
          goal.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: goal.completed ? mutedColor : textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            decoration: goal.completed ? TextDecoration.lineThrough : null,
            decorationColor: mutedColor,
          ),
        ),
        subtitle: goal.timeframe == 'Anytime'
            ? null
            : Text(
                goal.timeframe,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz_rounded, color: mutedColor),
          tooltip: 'Goal actions',
          onSelected: (value) {
            if (value == 'edit') {
              _showGoalDialog(goal: goal);
            } else if (value == 'delete') {
              _confirmDelete(goal);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(List<GoalModel> goals) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = goals.where((goal) => goal.completed).length;
    final totalCount = goals.length;
    final remainingCount = totalCount - completedCount;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF050606) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF222323) : const Color(0xFFE1E7E5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: _accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Daily Checklist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount completed',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: _accentColor,
                  backgroundColor: isDark
                      ? const Color(0xFF252525)
                      : const Color(0xFFE4EBE8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                remainingCount == 1
                    ? '1 goal left to do'
                    : '$remainingCount goals left to do',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              if (goals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Text(
                      'No goals yet. Add one to get started.',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                ...goals.map(_buildGoalRow),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalDialog(),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Goals',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your progress',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              StreamBuilder<List<GoalModel>>(
                stream: _goalsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _visibleGoals.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Unable to load goals: ${snapshot.error}'),
                    );
                  }

                  final goals = snapshot.hasData
                      ? _applyPendingGoalCompletion(snapshot.data ?? const [])
                      : _visibleGoals;

                  return _buildChecklist(goals);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
