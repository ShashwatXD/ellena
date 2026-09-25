import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskSearchState {
  const TaskSearchState({this.open = false, this.query = ''});

  final bool open;
  final String query;

  TaskSearchState copyWith({bool? open, String? query}) {
    return TaskSearchState(
      open: open ?? this.open,
      query: query ?? this.query,
    );
  }
}

final taskSearchProvider =
    NotifierProvider<TaskSearchNotifier, TaskSearchState>(TaskSearchNotifier.new);

class TaskSearchNotifier extends Notifier<TaskSearchState> {
  @override
  TaskSearchState build() => const TaskSearchState();

  void open() => state = state.copyWith(open: true);

  void setQuery(String query) => state = state.copyWith(query: query);

  void close() => state = const TaskSearchState();
}
