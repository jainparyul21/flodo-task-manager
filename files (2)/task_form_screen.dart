import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../services/draft_service.dart';
import '../theme/app_theme.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  final List<Task>? allTasks;

  const TaskFormScreen({super.key, this.task, this.allTasks});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _draft = DraftService();

  String _status = 'To-Do';
  DateTime? _dueDate;
  int? _blockedById;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _status = t.status;
      _blockedById = t.blockedById;
      try {
        _dueDate = DateTime.parse(t.dueDate);
      } catch (_) {}
    } else {
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    final draft = await _draft.loadDraft();
    if (draft != null) {
      setState(() {
        _titleCtrl.text = draft['title'] ?? '';
        _descCtrl.text = draft['description'] ?? '';
        _status = draft['status'] ?? 'To-Do';
        if (draft['due_date'] != null) {
          try {
            _dueDate = DateTime.parse(draft['due_date']!);
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _saveDraft() async {
    if (_isEditing) return;
    await _draft.saveDraft({
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'status': _status,
      'due_date': _dueDate?.toIso8601String().split('T').first ?? '',
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: FlodoTheme.neonPurple,
            surface: FlodoTheme.surfaceElevated,
            onSurface: FlodoTheme.textPrimary,
          ),
          dialogBackgroundColor: FlodoTheme.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _saveDraft();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a due date',
              style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: FlodoTheme.neonRose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'due_date': DateFormat('yyyy-MM-dd').format(_dueDate!),
      'status': _status,
      'blocked_by_id': _blockedById,
    };

    try {
      if (_isEditing) {
        await ref.read(tasksProvider.notifier).updateTask(widget.task!.id, data);
      } else {
        await ref.read(tasksProvider.notifier).createTask(data);
        await _draft.clearDraft();
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}',
                style: GoogleFonts.dmSans(color: Colors.white)),
            backgroundColor: FlodoTheme.neonRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherTasks = (widget.allTasks ?? [])
        .where((t) => t.id != widget.task?.id)
        .toList();

    return Scaffold(
      backgroundColor: FlodoTheme.bg,
      appBar: AppBar(
        backgroundColor: FlodoTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: FlodoTheme.textSecondary),
          onPressed: () {
            _saveDraft();
            Navigator.pop(context);
          },
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.syne(
              color: FlodoTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        centerTitle: false,
        actions: [
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () async {
                  await _draft.clearDraft();
                  _titleCtrl.clear();
                  _descCtrl.clear();
                  setState(() {
                    _status = 'To-Do';
                    _dueDate = null;
                    _blockedById = null;
                  });
                },
                child: Text('Clear',
                    style: GoogleFonts.dmSans(
                        color: FlodoTheme.textMuted, fontSize: 13)),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection('TASK DETAILS', [
              _buildField(
                controller: _titleCtrl,
                label: 'Title',
                hint: 'What needs to be done?',
                onChanged: (_) => _saveDraft(),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _descCtrl,
                label: 'Description',
                hint: 'Add more details (optional)...',
                onChanged: (_) => _saveDraft(),
                maxLines: 3,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('SCHEDULING', [
              _buildDatePicker(),
              const SizedBox(height: 12),
              _buildStatusDropdown(),
            ]),
            const SizedBox(height: 24),
            _buildSection('DEPENDENCIES', [
              _buildBlockedByDropdown(otherTasks),
            ]),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(
              begin: 0.05,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _buildSection(String label, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            label,
            style: GoogleFonts.dmMono(
              fontSize: 10,
              color: FlodoTheme.neonPurple,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlodoTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FlodoTheme.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(color: FlodoTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.neonPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.neonRose),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: FlodoTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: FlodoTheme.neonPurple),
            const SizedBox(width: 10),
            Text(
              _dueDate != null
                  ? DateFormat('EEEE, MMM d, yyyy').format(_dueDate!)
                  : 'Select due date',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: _dueDate != null
                    ? FlodoTheme.textPrimary
                    : FlodoTheme.textMuted,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: FlodoTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      onChanged: (v) {
        if (v != null) setState(() => _status = v);
        _saveDraft();
      },
      dropdownColor: FlodoTheme.surfaceElevated,
      style: GoogleFonts.dmSans(color: FlodoTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(FlodoTheme.statusIcon(_status),
            color: FlodoTheme.statusColor(_status), size: 18),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.neonPurple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: ['To-Do', 'In Progress', 'Done']
          .map((s) => DropdownMenuItem(
                value: s,
                child: Row(
                  children: [
                    Icon(FlodoTheme.statusIcon(s),
                        color: FlodoTheme.statusColor(s), size: 16),
                    const SizedBox(width: 8),
                    Text(s,
                        style: GoogleFonts.dmSans(
                            color: FlodoTheme.textPrimary, fontSize: 14)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBlockedByDropdown(List<Task> others) {
    return DropdownButtonFormField<int?>(
      value: _blockedById,
      onChanged: (v) => setState(() => _blockedById = v),
      dropdownColor: FlodoTheme.surfaceElevated,
      style: GoogleFonts.dmSans(color: FlodoTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Blocked By (optional)',
        hintText: 'None',
        prefixIcon: const Icon(Icons.link_rounded,
            color: FlodoTheme.textMuted, size: 18),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FlodoTheme.neonPurple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('— None —',
              style: GoogleFonts.dmSans(
                  color: FlodoTheme.textMuted, fontSize: 14)),
        ),
        ...others.map((t) => DropdownMenuItem<int?>(
              value: t.id,
              child: Row(
                children: [
                  Icon(FlodoTheme.statusIcon(t.status),
                      color: FlodoTheme.statusColor(t.status), size: 14),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(t.title,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                            color: FlodoTheme.textPrimary, fontSize: 13)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: 200.ms,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _saving
                ? FlodoTheme.neonPurple.withOpacity(0.5)
                : FlodoTheme.neonPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: _saving ? 0 : 8,
            shadowColor: FlodoTheme.neonPurple.withOpacity(0.4),
          ),
          child: _saving
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Saving...',
                        style: GoogleFonts.syne(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                )
              : Text(
                  _isEditing ? 'Update Task' : 'Create Task',
                  style: GoogleFonts.syne(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
        ),
      ),
    );
  }
}
