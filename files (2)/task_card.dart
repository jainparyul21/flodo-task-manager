import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final List<Task> allTasks;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.allTasks,
    required this.onTap,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final blocked = task.isBlocked(allTasks);
    final statusColor = FlodoTheme.statusColor(task.status);
    final now = DateTime.now();
    DateTime? dueDate;
    bool isOverdue = false;
    try {
      dueDate = DateTime.parse(task.dueDate);
      isOverdue = task.status != 'Done' && dueDate.isBefore(now);
    } catch (_) {}

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 60).ms),
        SlideEffect(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
          duration: 350.ms,
          delay: (index * 60).ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Opacity(
        opacity: blocked ? 0.45 : 1.0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: FlodoTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: blocked
                    ? FlodoTheme.border
                    : statusColor.withOpacity(0.25),
                width: 1,
              ),
              boxShadow: blocked
                  ? []
                  : [
                      BoxShadow(
                        color: statusColor.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Left accent bar
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: blocked ? FlodoTheme.border : statusColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status icon
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            blocked
                                ? Icons.lock_outline_rounded
                                : FlodoTheme.statusIcon(task.status),
                            color: blocked ? FlodoTheme.textMuted : statusColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: GoogleFonts.syne(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: blocked
                                            ? FlodoTheme.textMuted
                                            : FlodoTheme.textPrimary,
                                        decoration: task.status == 'Done'
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: FlodoTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  _StatusBadge(
                                    status: task.status,
                                    blocked: blocked,
                                  ),
                                ],
                              ),
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: FlodoTheme.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 11,
                                    color: isOverdue
                                        ? FlodoTheme.neonRose
                                        : FlodoTheme.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dueDate != null
                                        ? DateFormat('MMM d, yyyy')
                                            .format(dueDate)
                                        : task.dueDate,
                                    style: GoogleFonts.dmMono(
                                      fontSize: 11,
                                      color: isOverdue
                                          ? FlodoTheme.neonRose
                                          : FlodoTheme.textMuted,
                                    ),
                                  ),
                                  if (isOverdue) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: FlodoTheme.neonRose
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'OVERDUE',
                                        style: GoogleFonts.dmMono(
                                          fontSize: 9,
                                          color: FlodoTheme.neonRose,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (blocked) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: FlodoTheme.textMuted
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'BLOCKED',
                                        style: GoogleFonts.dmMono(
                                          fontSize: 9,
                                          color: FlodoTheme.textMuted,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  // Drag handle hint
                                  Icon(
                                    Icons.drag_indicator_rounded,
                                    size: 16,
                                    color: FlodoTheme.textMuted.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Delete button
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.close_rounded),
                          iconSize: 16,
                          color: FlodoTheme.textMuted,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                FlodoTheme.border.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool blocked;

  const _StatusBadge({required this.status, required this.blocked});

  @override
  Widget build(BuildContext context) {
    final color = blocked
        ? FlodoTheme.textMuted
        : FlodoTheme.statusColor(status);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        blocked ? 'Blocked' : status,
        style: GoogleFonts.dmMono(
          fontSize: 10,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
