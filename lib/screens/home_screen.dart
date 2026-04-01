import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  String _statusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _allTasks = tasks;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        final matchesSearch = task.title
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesStatus =
            _statusFilter == 'All' || task.status == _statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _deleteTask(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _loadTasks();
  }

  bool _isBlocked(Task task) {
    if (task.blockedBy == null) return false;
    final blocker = _allTasks.firstWhere(
      (t) => t.id == task.blockedBy,
      orElse: () => Task(
          title: '', description: '', dueDate: '', status: 'Done'),
    );
    return blocker.status != 'Done';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Task Manager',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6C63FF),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF6C63FF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'To-Do', 'In Progress', 'Done']
                        .map((status) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(status),
                                selected: _statusFilter == status,
                                onSelected: (selected) {
                                  setState(() {
                                    _statusFilter = status;
                                    _applyFilters();
                                  });
                                },
                                selectedColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                labelStyle: TextStyle(
                                  color: _statusFilter == status
                                      ? const Color(0xFF6C63FF)
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No tasks found',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final blocked = _isBlocked(task);
                      return _buildTaskCard(task, blocked);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskFormScreen(allTasks: _allTasks)),
          );
          _loadTasks();
        },
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('New Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTaskCard(Task task, bool blocked) {
    Color statusColor;
    switch (task.status) {
      case 'In Progress':
        statusColor = const Color(0xFFFF9800);
        break;
      case 'Done':
        statusColor = const Color(0xFF4CAF50);
        break;
      default:
        statusColor = const Color(0xFF2196F3);
    }

    return Opacity(
      opacity: blocked ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: blocked
                ? Border.all(color: Colors.grey, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration:
                          blocked ? TextDecoration.none : TextDecoration.none,
                      color: blocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                if (blocked)
                  const Icon(Icons.lock, color: Colors.grey, size: 18),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(task.description,
                    style: TextStyle(
                        color: blocked ? Colors.grey : Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14,
                        color: blocked ? Colors.grey : Colors.black54),
                    const SizedBox(width: 4),
                    Text(task.dueDate,
                        style: TextStyle(
                            fontSize: 12,
                            color: blocked ? Colors.grey : Colors.black54)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: blocked
                            ? Colors.grey.withOpacity(0.2)
                            : statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: blocked ? Colors.grey : statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (blocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      '🔒 Blocked by another task',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(
                            task: task, allTasks: _allTasks),
                      ),
                    );
                    _loadTasks();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _showDeleteDialog(task),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(task.id);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}