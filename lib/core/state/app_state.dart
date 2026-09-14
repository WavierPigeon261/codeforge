import 'package:flutter/foundation.dart';
import '../models/project_model.dart';

enum WorkspacePanel {
  aiChat,
  fileExplorer,
  terminal,
}

enum AiProvider {
  antigravityCli,
  openCode,
  geminiPro,
  claudeSonnet,
}

class AppStateNotifier extends ChangeNotifier {
  ProjectModel? _activeProject;
  WorkspacePanel _activePanel = WorkspacePanel.fileExplorer;
  AiProvider _selectedAiProvider = AiProvider.antigravityCli;

  String? _selectedFilePath;
  String _activeFileContent = '';
  final List<String> _openFilePaths = [];

  final List<ProjectModel> _recentProjects = [
    ProjectModel(
      id: 'demo-1',
      name: 'mobile-ide',
      path: '/workspace/mobile-ide',
      lastOpened: DateTime.now().subtract(const Duration(minutes: 5)),
      description: 'Mobile-first Android IDE app built with Flutter',
    ),
  ];

  // Getters
  ProjectModel? get activeProject => _activeProject;
  WorkspacePanel get activePanel => _activePanel;
  AiProvider get selectedAiProvider => _selectedAiProvider;
  List<ProjectModel> get recentProjects => List.unmodifiable(_recentProjects);
  String? get selectedFilePath => _selectedFilePath;
  String get activeFileContent => _activeFileContent;
  List<String> get openFilePaths => List.unmodifiable(_openFilePaths);

  // Setters & Methods
  void openProject(ProjectModel project) {
    _activeProject = project.copyWith(lastOpened: DateTime.now());
    
    // Update recent projects list
    _recentProjects.removeWhere((p) => p.path == project.path);
    _recentProjects.insert(0, _activeProject!);

    notifyListeners();
  }

  void closeProject() {
    _activeProject = null;
    _selectedFilePath = null;
    _activeFileContent = '';
    _openFilePaths.clear();
    notifyListeners();
  }

  void setActivePanel(WorkspacePanel panel) {
    _activePanel = panel;
    notifyListeners();
  }

  void setAiProvider(AiProvider provider) {
    _selectedAiProvider = provider;
    notifyListeners();
  }

  void openFile(String filePath, String content) {
    _selectedFilePath = filePath;
    _activeFileContent = content;
    if (!_openFilePaths.contains(filePath)) {
      _openFilePaths.add(filePath);
    }
    notifyListeners();
  }

  void closeFile(String filePath) {
    _openFilePaths.remove(filePath);
    if (_selectedFilePath == filePath) {
      _selectedFilePath = _openFilePaths.isNotEmpty ? _openFilePaths.last : null;
    }
    notifyListeners();
  }

  void addProject(ProjectModel project) {
    _recentProjects.insert(0, project);
    _activeProject = project;
    notifyListeners();
  }
}
