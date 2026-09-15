import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import 'panels/ai_chat_panel.dart';
import 'panels/file_explorer_panel.dart';
import 'panels/terminal_panel.dart';
import 'widgets/editor_view.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppStateNotifier>();
    final activeProj = appState.activeProject;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.closeProject(),
          tooltip: 'Return to Dashboard',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeProj?.name ?? 'Mobile IDE Workspace',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              activeProj?.path ?? '/workspace/',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.green),
            onPressed: () {
              appState.setActivePanel(WorkspacePanel.terminal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Switched to Terminal. Run "flutter build apk" to compile.')),
              );
            },
            tooltip: 'Run App / Build',
          ),
        ],
      ),
      body: Column(
        children: [
          // Open Editor Tabs Bar
          if (appState.openFilePaths.isNotEmpty)
            Container(
              height: 40,
              color: theme.colorScheme.surfaceContainer,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appState.openFilePaths.length,
                itemBuilder: (context, index) {
                  final filePath = appState.openFilePaths[index];
                  final fileName = filePath.split('/').last;
                  final isSelected = appState.selectedFilePath == filePath;

                  return Container(
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainer,
                      border: isSelected
                          ? Border(
                              top: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: InkWell(
                      onTap: () {
                        appState.openFile(
                          filePath,
                          appState.activeFileContent,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => appState.closeFile(filePath),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Central Editor / Panel Workspace Viewport
          Expanded(
            child: Row(
              children: [
                // Active Side Panel (Panel A, B, or C)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildActivePanel(appState.activePanel),
                  ),
                ),

                // Central Code Editor View
                Expanded(
                  flex: 3,
                  child: appState.selectedFilePath != null
                      ? EditorView(
                          key: ValueKey(appState.selectedFilePath),
                          filePath: appState.selectedFilePath!,
                          initialContent: appState.activeFileContent,
                        )
                      : Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.developer_mode,
                                  size: 64,
                                  color: theme.colorScheme.outlineVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No File Open',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select a file from Panel B (Explorer) to edit.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Material 3 NavigationBar for Panel Switching
      bottomNavigationBar: NavigationBar(
        selectedIndex: appState.activePanel.index,
        onDestinationSelected: (index) {
          appState.setActivePanel(WorkspacePanel.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Panel A (AI Chat)',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Panel B (Files)',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: 'Panel C (Terminal)',
          ),
        ],
      ),
    );
  }

  Widget _buildActivePanel(WorkspacePanel panel) {
    switch (panel) {
      case WorkspacePanel.aiChat:
        return const AiChatPanel();
      case WorkspacePanel.fileExplorer:
        return const FileExplorerPanel();
      case WorkspacePanel.terminal:
        return const TerminalPanel();
    }
  }
}
