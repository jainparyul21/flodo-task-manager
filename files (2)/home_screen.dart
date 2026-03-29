import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  static const _statuses = ['All', 'To-Do', 'In Progress', 'Done'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = val;
      ref.read(tasksProvider.notifier).refresh();
    });
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlodoTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete task?',
            style: GoogleFonts.syne(
                color: FlodoTheme.textPrimary, fontWeight: FontWeight.w600)),
        content: Text(
          '"${task.title}" will be permanently removed.',
          style: GoogleFonts.dmSans(color: FlodoTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: FlodoTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tasksProvider.notifier).deleteTask(task.id);
            },
            child: Text('Delete',
                style: GoogleFonts.dmSans(color: FlodoTheme.neonRose)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final selectedStatus = ref.watch(statusFilterProvider);

    return Scaffold(
      backgroundColor: FlodoTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildStatusFilter(selectedStatus),
            Expanded(
              child: tasksAsync.when(
                loading: () => _buildLoading(),
                error: (e, _) => _buildError(e),
                data: (tasks) => _buildList(tasks),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FLODO',
                  style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: FlodoTheme.textPrimary,
                    letterSpacing: 4,
                  )).animate().fadeIn(duration: 400.ms),
              Text('your task os',
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    color: FlodoTheme.neonPurple,
                    letterSpacing: 2,
                  )).animate().fadeIn(delay: 100.ms),
            ],
          ),
          const Spacer(),
          // Stats pill
          ref.watch(tasksProvider).whenOrNull(
                data: (tasks) {
                  final done = tasks.where((t) => t.status == 'Done').length;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: FlodoTheme.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: FlodoTheme.neonGreen.withOpacity(0.2)),
                    ),
                    child: Text(
                      '$done / ${tasks.length} done',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        color: FlodoTheme.neonGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms);
                },
              ) ??
              const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: GoogleFonts.dmSans(color: FlodoTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: FlodoTheme.textMuted, size: 18),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: FlodoTheme.textMuted, size: 16),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatusFilter(String selected) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: _statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _statuses[i];
          final isSelected = s == selected;
          final color = s == 'All'
              ? FlodoTheme.neonPurple
              : FlodoTheme.statusColor(s);
          return GestureDetector(
            onTap: () {
              ref.read(statusFilterProvider.notifier).state = s;
              ref.read(tasksProvider.notifier).refresh();
            },
            child: AnimatedContainer(
              duration: 200.ms,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : FlodoTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? color.withOpacity(0.4)
                      : FlodoTheme.border,
                  width: 1,
                ),
              ),
              child: Text(
                s,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : FlodoTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 48, color: FlodoTheme.textMuted.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('No tasks yet',
                style: GoogleFonts.syne(
                    color: FlodoTheme.textMuted, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Tap + to create your first task',
                style: GoogleFonts.dmSans(
                    color: FlodoTheme.textMuted.withOpacity(0.6),
                    fontSize: 13)),
          ],
        ),
      ).animate().fadeIn();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final reordered = List<Task>.from(tasks);
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        ref.read(tasksProvider.notifier).reorder(reordered);
      },
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 1.0, end: 1.03)
              .chain(CurveTween(curve: Curves.easeOut))),
          child: child,
        ),
      ),
      itemBuilder: (context, i) {
        final task = tasks[i];
        return KeyedSubtree(
          key: ValueKey(task.id),
          child: TaskCard(
            task: task,
            allTasks: tasks,
            index: i,
            onTap: () => _openEdit(context, task, tasks),
            onDelete: () => _confirmDelete(context, task),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(FlodoTheme.neonPurple),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 40, color: FlodoTheme.neonRose),
          const SizedBox(height: 12),
          Text('Cannot connect to server',
              style: GoogleFonts.syne(
                  color: FlodoTheme.textPrimary, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Make sure the backend is running',
              style: GoogleFonts.dmSans(
                  color: FlodoTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.read(tasksProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: FlodoTheme.neonPurple,
              side: const BorderSide(color: FlodoTheme.neonPurple),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openCreate(context),
      backgroundColor: FlodoTheme.neonPurple,
      foregroundColor: Colors.white,
      elevation: 8,
      extendedPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text('New Task',
          style: GoogleFonts.syne(fontWeight: FontWeight.w600, fontSize: 13)),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .slideY(begin: 0.3, end: 0, delay: 400.ms, curve: Curves.easeOutCubic);
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }

  void _openEdit(BuildContext context, Task task, List<Task> allTasks) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TaskFormScreen(task: task, allTasks: allTasks)),
    );
  }
}
