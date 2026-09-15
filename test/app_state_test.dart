import 'package:flutter_test/flutter_test.dart';
import 'package:codeforge/core/models/project_model.dart';
import 'package:codeforge/core/state/app_state.dart';

void main() {
  group('AppStateNotifier Unit Tests', () {
    late AppStateNotifier appState;

    setUp(() {
      appState = AppStateNotifier();
    });

    test('Initial active project is null', () {
      expect(appState.activeProject, isNull);
    });

    test('Opening project updates activeProject and recent list', () {
      final project = ProjectModel(
        id: 'test-1',
        name: 'test_project',
        path: '/workspace/test_project',
        lastOpened: DateTime.now(),
      );

      appState.openProject(project);
      expect(appState.activeProject?.name, equals('test_project'));
      expect(appState.recentProjects.first.path, equals('/workspace/test_project'));
    });

    test('Switching workspace panels updates activePanel state', () {
      appState.setActivePanel(WorkspacePanel.aiChat);
      expect(appState.activePanel, equals(WorkspacePanel.aiChat));

      appState.setActivePanel(WorkspacePanel.terminal);
      expect(appState.activePanel, equals(WorkspacePanel.terminal));
    });

    test('Opening and closing files updates openFilePaths', () {
      appState.openFile('/workspace/mobile-ide/lib/main.dart', 'void main() {}');
      expect(appState.selectedFilePath, equals('/workspace/mobile-ide/lib/main.dart'));
      expect(appState.openFilePaths.contains('/workspace/mobile-ide/lib/main.dart'), isTrue);

      appState.closeFile('/workspace/mobile-ide/lib/main.dart');
      expect(appState.openFilePaths.contains('/workspace/mobile-ide/lib/main.dart'), isFalse);
    });
  });
}
