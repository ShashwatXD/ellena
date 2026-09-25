import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_search_provider.dart';

enum WorkspaceTab { tasks, agent }

final workspaceTabProvider =
    NotifierProvider<WorkspaceTabNotifier, WorkspaceTab>(
      WorkspaceTabNotifier.new,
    );

class WorkspaceTabNotifier extends Notifier<WorkspaceTab> {
  @override
  WorkspaceTab build() => WorkspaceTab.agent;

  void select(WorkspaceTab tab) {
    if (state == tab) return;
    state = tab;
    if (tab != WorkspaceTab.tasks) {
      ref.read(taskSearchProvider.notifier).close();
    }
  }
}
