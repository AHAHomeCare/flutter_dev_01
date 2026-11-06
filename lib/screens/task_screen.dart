import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/sona_task_api.dart';

import '../widgets/add_task_form.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.onPendingChanged, this.api});
  final ValueChanged<int> onPendingChanged;
  final SonaTaskApi? api;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final http.Client _client = http.Client();
  SonaTaskApi get _api => widget.api ?? _defaultApi;
  late final _defaultApi = SonaTaskApi(_client, _apiBaseUrl);
  static final _apiBaseUrl = const bool.hasEnvironment('SONATASK_API_URL')
      ? const String.fromEnvironment('SONATASK_API_URL')
      : !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:5279'
      : 'http://localhost:5279';

  final List<SonaTask> _tasks = [];
  final Set<int> _doneIds = {};
  final Map<int, String> _priorities = {};
  bool _onlyPending = false;
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    if (widget.api == null) _client.close();
    super.dispose();
  }

  void _notifyPendingCount() {
    widget.onPendingChanged(
      _tasks.where((task) => !_doneIds.contains(task.id)).length,
    );
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final tasks = await _api.getAll();
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(tasks);
        _loading = false;
      });
      _notifyPendingCount();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _loading = false;
      });
    }
  }

  Future<void> _addTask(
    String title,
    String description,
    String priority,
  ) async {
    setState(() => _saving = true);
    try {
      final task = await _api.create(title, description);
      if (!mounted) return;
      setState(() {
        _tasks.add(task);
        _priorities[task.id] = priority;
      });
      _notifyPendingCount();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleTask(SonaTask task, bool? value) {
    setState(() {
      if (value == true) {
        _doneIds.add(task.id);
      } else {
        _doneIds.remove(task.id);
      }
    });
    _notifyPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Không tải được công việc từ API.'),
            TextButton(onPressed: _loadTasks, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    final done = _tasks.where((task) => _doneIds.contains(task.id)).length;
    final visibleTasks = _onlyPending
        ? _tasks.where((task) => !_doneIds.contains(task.id)).toList()
        : _tasks;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Thêm công việc',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        AddTaskForm(onAdd: _addTask),
        TextButton.icon(
          onPressed: _saving ? null : _loadTasks,
          icon: const Icon(Icons.refresh),
          label: const Text('Tải lại danh sách'),
        ),
        const SizedBox(height: 24),
        // Giữ StatCard và cách bố trí responsive đã học ở Bài 02.
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              StatCard(
                label: 'Tổng công việc',
                value: _tasks.length,
                icon: Icons.assignment_outlined,
                color: const Color(0xFF315ACB),
              ),
              StatCard(
                label: 'Đã xong',
                value: done,
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16815D),
              ),
              StatCard(
                label: 'Chưa xong',
                value: _tasks.length - done,
                icon: Icons.schedule,
                color: const Color(0xFFAA6514),
              ),
            ];
            if (constraints.maxWidth >= 600 &&
                MediaQuery.textScalerOf(context).scale(14) <= 21) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  cards[i],
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Danh sách công việc',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text('${_tasks.length} công việc • $done đã hoàn thành'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Chỉ hiện việc chưa hoàn thành'),
          value: _onlyPending,
          onChanged: (value) {
            setState(() {
              _onlyPending = value;
            });
          },
        ),
        if (visibleTasks.isEmpty)
          const Text('Không có công việc phù hợp với bộ lọc.'),
        for (final task in visibleTasks)
          TaskCard(
            key: ValueKey(task.id),
            task: task,
            isDone: _doneIds.contains(task.id),
            priority: _priorities[task.id] ?? 'Bình thường',
            onChanged: (value) => _toggleTask(task, value),
          ),
        const SizedBox(height: 16),
        const Text('Trạng thái và ưu tiên chỉ lưu trong phiên hiện tại.'),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.isDone,
    required this.priority,
    required this.onChanged,
  });
  final SonaTask task;
  final bool isDone;
  final String priority;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = isDone ? const Color(0xFF16815D) : const Color(0xFF315ACB);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack đặt chấm trạng thái lên góc biểu tượng công việc.
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_outlined, color: color),
                ),
                if (isDone)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF16815D),
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (task.description.isNotEmpty) Text(task.description),
                  Text('Ưu tiên: $priority'),
                  const SizedBox(height: 8),
                  Text(
                    isDone ? 'Đã xong' : 'Chưa xong',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isDone,
              onChanged: onChanged,
              semanticLabel: 'Hoàn thành ${task.name}',
            ),
          ],
        ),
      ),
    );
  }
}
