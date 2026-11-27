import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/sona_task_api.dart';

import '../widgets/add_task_form.dart';

enum TaskFilter {
  all('Tất cả', null),
  pending('Chưa hoàn thành', false),
  done('Đã hoàn thành', true);

  const TaskFilter(this.label, this.isDone);

  final String label;
  final bool? isDone;
}

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
      ? 'https://sona.somee.com/api/v1'
      : 'http://localhost:5279';

  List<SonaTask> _tasks = [];
  List<SonaTask> _visibleTasks = [];
  final Map<int, String> _priorities = {};
  final Set<int> _updatingIds = {};
  TaskFilter _filter = TaskFilter.all;
  int _loadVersion = 0;
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

  Future<void> _loadTasks() async {
    final version = ++_loadVersion;
    final status = _filter.isDone;
    setState(() {
      _loading = true;
      _loadFailed = false;
    });

    try {
      final all = _api.getAll();
      final lists = await Future.wait([
        all,
        if (status != null) _api.getTaskByStatus(status),
      ]);
      if (!mounted || version != _loadVersion) return;
      setState(() {
        _tasks = lists.first;
        _visibleTasks = lists.last;
        _loading = false;
      });
      widget.onPendingChanged(_tasks.where((task) => !task.isDone).length);
    } catch (_) {
      if (!mounted || version != _loadVersion) return;
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
      final task = await _api.createTask(title, description);
      if (!mounted) return;
      _priorities[task.id] = priority;
      await _loadTasks();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleTask(SonaTask task, bool? value) async {
    if (value == null || _updatingIds.contains(task.id)) return;
    setState(() => _updatingIds.add(task.id));
    try {
      await _api.updateStatusTask(task.id, value);
      if (!mounted) return;
      await _loadTasks();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không cập nhật được trạng thái công việc.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingIds.remove(task.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((task) => task.isDone).length;
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

        Wrap(
          spacing: 8,
          children: [
            for (final filter in TaskFilter.values)
              ChoiceChip(
                label: Text(filter.label),
                selected: _filter == filter,
                onSelected: (selected) {
                  if (!selected || _filter == filter) return;
                  setState(() => _filter = filter);
                  _loadTasks();
                },
              ),
          ],
        ),
        if (_loading)
          const LinearProgressIndicator()
        else if (_loadFailed) ...[
          const Text('Không tải được công việc từ API.'),
          TextButton(onPressed: _loadTasks, child: const Text('Thử lại')),
        ] else if (_visibleTasks.isEmpty)
          const Text('Không có công việc phù hợp với bộ lọc.')
        else
          for (final task in _visibleTasks)
            TaskCard(
              key: ValueKey(task.id),
              task: task,
              isDone: task.isDone,
              priority: _priorities[task.id] ?? 'Bình thường',
              onChanged: _updatingIds.contains(task.id)
                  ? null
                  : (value) => _toggleTask(task, value),
            ),
        const SizedBox(height: 16),
        const Text(
          'Trạng thái được lưu trên máy chủ. Ưu tiên chỉ lưu trong phiên hiện tại.',
        ),
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
  final ValueChanged<bool?>? onChanged;

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
