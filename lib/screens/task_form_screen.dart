import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final List<Task> allTasks;

  const TaskFormScreen({super.key, this.task, required this.allTasks});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _status = 'To-Do';
  String? _blockedBy;
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _status = widget.task!.status;
      _blockedBy = widget.task!.blockedBy;
      _dueDate = DateTime.parse(widget.task!.dueDate);
    } else {
      _loadDraft();
    }
    _titleController.addListener(_saveDraft);
    _descController.addListener(_saveDraft);
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_title') ?? '';
      _descController.text = prefs.getString('draft_desc') ?? '';
    });
  }

  Future<void> _saveDraft() async {
    if (_isEditing) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleController.text);
    await prefs.setString('draft_desc', _descController.text);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_desc');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    final task = Task(
      id: _isEditing ? widget.task!.id : null,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _dueDate!.toIso8601String().split('T')[0],
      status: _status,
      blockedBy: _blockedBy,
    );

    if (_isEditing) {
      await DatabaseHelper.instance.updateTask(task);
    } else {
      await DatabaseHelper.instance.insertTask(task);
      await _clearDraft();
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherTasks = widget.allTasks
        .where((t) => !_isEditing || t.id != widget.task!.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Title *'),
            _buildTextField(_titleController, 'Enter task title'),
            const SizedBox(height: 16),
            _buildLabel('Description'),
            _buildTextField(_descController, 'Enter description',
                maxLines: 3),
            const SizedBox(height: 16),
            _buildLabel('Due Date *'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF6C63FF), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate == null
                          ? 'Select due date'
                          : DateFormat('MMM dd, yyyy').format(_dueDate!),
                      style: TextStyle(
                        color: _dueDate == null
                            ? Colors.grey
                            : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Status'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  items: ['To-Do', 'In Progress', 'Done']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _status = value!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Blocked By (Optional)'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _blockedBy,
                  hint: const Text('None'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('None')),
                    ...otherTasks.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.title,
                              overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (value) =>
                      setState(() => _blockedBy = value),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Saving...',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ],
                      )
                    : const Text(
                        'Save Task',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }
}