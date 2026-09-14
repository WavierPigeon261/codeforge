import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/project_model.dart';
import '../../../core/state/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final pathController = TextEditingController(text: '/workspace/');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.create_new_folder_outlined),
          title: const Text('Create New Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'my_flutter_app',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pathController,
                decoration: const InputDecoration(
                  labelText: 'Parent Directory Path',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                final path = '${pathController.text.trim()}/$name';
                if (name.isNotEmpty) {
                  final newProject = ProjectModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    path: path,
                    lastOpened: DateTime.now(),
                    description: 'Newly created project directory',
                  );
                  context.read<AppStateNotifier>().addProject(newProject);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showCloneRepoDialog(BuildContext context) {
    final repoUrlController = TextEditingController();
    final targetPathController = TextEditingController(text: '/workspace/');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.cloud_download_outlined),
          title: const Text('Clone GitHub Repository'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Repository URL',
                  hintText: 'https://github.com/user/repository.git',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetPathController,
                decoration: const InputDecoration(
                  labelText: 'Target Directory Path',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                final url = repoUrlController.text.trim();
                if (url.isNotEmpty) {
                  final repoName = url.split('/').last.replaceAll('.git', '');
                  final path = '${targetPathController.text.trim()}/$repoName';
                  final clonedProject = ProjectModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: repoName,
                    path: path,
                    gitUrl: url,
                    lastOpened: DateTime.now(),
                    description: 'Cloned from $url',
                  );
                  context.read<AppStateNotifier>().addProject(clonedProject);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Clone'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppStateNotifier>();
    final recentProjects = appState.recentProjects;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.terminal_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Mobile IDE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: 'IDE Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Mobile IDE',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mobile-first Android IDE powered by Flutter & Proot Linux environment.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: InkWell(
                      onTap: () => _showCreateProjectDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_box_rounded,
                              size: 32,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'New Project',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: InkWell(
                      onTap: () => _showCloneRepoDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_download_rounded,
                              size: 32,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Clone Git Repo',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Recent Projects Card Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Projects',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (recentProjects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No recent projects found',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: recentProjects.length,
                itemBuilder: (context, index) {
                  final project = recentProjects[index];
                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        appState.openProject(project);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.folder_special,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (project.gitUrl != null)
                                  Icon(
                                    Icons.account_tree_outlined,
                                    size: 16,
                                    color: theme.colorScheme.outline,
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  project.path,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
