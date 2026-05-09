import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('งานของฉัน'),
            if (provider.pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${provider.pendingCount}',
                  style: const TextStyle(
                    fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  // Filter Bar
  Widget _buildFilterBar(TodoProvider provider) {
    const filters = [
      ('all', 'ทั้งหมด'),
      ('pending', 'ยังไม่เสร็จ'),
      ('done', 'เสร็จแล้ว'),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final isSelected = provider.filter == f.$1;
          return GestureDetector(
            onTap: () => provider.setFilter(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(f.$2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(TodoProvider provider) {
    if (provider.status == TodoStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text('ไม่มีงานค้าง!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('เพิ่มงานใหม่เพื่อเริ่มติดตาม',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มงาน'),
              onPressed: () => _showAddSheet(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.todos.length,
      itemBuilder: (_, i) => _TodoCard(
        todo: provider.todos[i],
        onToggle: (id) => context.read<TodoProvider>().toggleDone(id),
        onDelete: (id) => context.read<TodoProvider>().deleteTodo(id),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTodoSheet(),
    );
  }
}

// ===== Todo Card =====
class _TodoCard extends StatelessWidget {
  final TodoModel todo;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = todo.daysLeft;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(todo.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: todo.isDone
              ? AppColors.background
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: todo.priorityColor, width: 4),
          ),
          boxShadow: todo.isDone ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => onToggle(todo.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.isDone ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: todo.isDone ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                ),
                child: todo.isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // ข้อมูล
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: todo.isDone
                          ? AppColors.textSecondary : AppColors.textPrimary,
                      decoration: todo.isDone
                          ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (todo.subject != null) ...[
                    const SizedBox(height: 3),
                    Text(todo.subject!,
                        style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary,
                        )),
                  ],
                  if (todo.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: daysLeft != null && daysLeft <= 1 && !todo.isDone
                              ? AppColors.error : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM', 'th').format(todo.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: daysLeft != null && daysLeft <= 1 && !todo.isDone
                                ? AppColors.error : AppColors.textSecondary,
                            fontWeight: daysLeft != null && daysLeft <= 1 && !todo.isDone
                                ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (daysLeft != null && !todo.isDone) ...[
                          const SizedBox(width: 6),
                          Text(
                            daysLeft == 0 ? '⚠️ วันนี้!'
                                : daysLeft < 0 ? '⏰ เลยกำหนด'
                                : 'อีก $daysLeft วัน',
                            style: TextStyle(
                              fontSize: 11,
                              color: daysLeft <= 0
                                  ? AppColors.error : AppColors.textSecondary,
                              fontWeight: daysLeft <= 0
                                  ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Priority badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: todo.priorityColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(todo.priorityLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: todo.priorityColor,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Add Todo Bottom Sheet =====
class _AddTodoSheet extends StatefulWidget {
  const _AddTodoSheet();

  @override
  State<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<_AddTodoSheet> {
  final _titleCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  String   _priority  = 'medium';
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: const Text('กรุณากรอกชื่องาน'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ok = await context.read<TodoProvider>().createTodo({
      'title':    _titleCtrl.text.trim(),
      'subject':  _subjectCtrl.text.trim().isEmpty ? null : _subjectCtrl.text.trim(),
      'priority': _priority,
      'due_date': _dueDate?.toIso8601String(),
    });

    if (!mounted) return;
    
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('เพิ่มงานสำเร็จ ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('เพิ่มไม่สำเร็จ'),
          content: Text(context.read<TodoProvider>().error ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const priorities = [
      ('high', 'ด่วนมาก', Color(0xFFE24B4A)),
      ('medium', 'ปานกลาง', Color(0xFFBA7517)),
      ('low', 'ไม่ด่วน', Color(0xFF1D9E75)),
    ];

    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 16),
            const Text('เพิ่มงานใหม่',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'ชื่องาน *',
              hint: 'เช่น ส่งรายงาน Chapter 3',
              controller: _titleCtrl,
              prefixIcon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 14),

            CustomTextField(
              label: 'วิชา',
              hint: 'เช่น Database Systems',
              controller: _subjectCtrl,
              prefixIcon: Icons.book_outlined,
            ),
            const SizedBox(height: 14),

            // Priority
            const Text('ความเร่งด่วน',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: priorities.map((p) {
                final isSelected = _priority == p.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? p.$3.withOpacity(0.15) : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? p.$3 : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(p.$1 == 'high' ? '🔴'
                              : p.$1 == 'medium' ? '🟡' : '🟢',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(p.$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? p.$3 : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Due date
            const Text('วันส่ง',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate != null
                          ? DateFormat('d MMMM yyyy', 'th').format(_dueDate!)
                          : 'เลือกวันส่ง',
                      style: TextStyle(
                        fontSize: 14,
                        color: _dueDate != null
                            ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              label: 'เพิ่มงาน',
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}