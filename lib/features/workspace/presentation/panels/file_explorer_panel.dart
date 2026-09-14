import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../file_explorer/services/file_system_service.dart';

class FileExplorerPanel extends StatefulWidget {
  const FileExplorerPanel({super.key});

  @override
  State<FileExplorerPanel> createState() => _FileExplorerPanelState();
}

class _FileExplorerPanelState extends State<FileExplorerPanel> {
  FileNode? _rootNode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTree();
  }

  Future<void> _refreshTree() async {
    setState(() {
      _isLoading = true;
    });

    final appState = context.read<AppStateNotifier>();
    final targetPath = appState.activeProject?.path ?? '/workspace/mobile-ide';
    
    final rootNode = await FileSystemService.scanDirectory(targetPath);

    if (!mounted) return;
    setState(() {
      _rootNode = rootNode;
      _isLoading = false;
    });
  }

  void _showNewFileDialog(BuildContext context, String parentDirPath) {
    final fileNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New File'),
          content: TextField(
            controller: fileNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. helper.dart',
              labelText: 'File Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = fileNameController.text.trim();
                if (name.isNotEmpty) {
                  await FileSystemService.createFile(parentDirPath, name);
                  Navigator.pop(context);
                  _refreshTree();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showNewFolderDialog(BuildContext context, String parentDirPath) {
    final folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Directory'),
          content: TextField(
            controller: folderNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. widgets',
              labelText: 'Directory Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = folderNameController.text.trim();
                if (name.isNotEmpty) {
                  await FileSystemService.createFolder(parentDirPath, name);
                  Navigator.pop(context);
                  _refreshTree();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileTreeNode(BuildContext context, FileNode node, int depth) {
    final appState = context.read<AppStateNotifier>();

    if (node.isDirectory) {
      return ExpansionTile(
        key: PageStorageKey(node.path),
        tilePadding: EdgeInsets.only(left: depth * 12.0 + 8.0, right: 8.0),
        leading: const Icon(Icons.folder_rounded, color: Colors.amber, size: 20),
        title: Text(
          node.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _showNewFileDialog(context, node.path),
              child: const Icon(Icons.note_add_outlined, size: 16),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => _showNewFolderDialog(context, node.path),
              child: const Icon(Icons.create_new_folder_outlined, size: 16),
            ),
          ],
        ),
        children: node.children
            .map((child) => _buildFileTreeNode(context, child, depth + 1))
            .toList(),
      );
    } else {
      final isSelected = appState.selectedFilePath == node.path;
      return ListTile(
        contentPadding: EdgeInsets.only(left: depth * 12.0 + 24.0, right: 8.0),
        dense: true,
        selected: isSelected,
        leading: Icon(
          _getFileIcon(node.name),
          size: 18,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          node.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () async {
          final content = await FileSystemService.readFile(node.path);
          appState.openFile(node.path, content);
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 16),
          onPressed: () async {
            await FileSystemService.deleteEntity(node.path);
            if (appState.selectedFilePath == node.path) {
              appState.closeFile(node.path);
            }
            _refreshTree();
          },
        ),
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.dart')) return Icons.code_rounded;
    if (fileName.endsWith('.yml') || fileName.endsWith('.yaml')) return Icons.settings_rounded;
    if (fileName.endsWith('.md')) return Icons.description_outlined;
    if (fileName.endsWith('.json')) return Icons.data_object_rounded;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppStateNotifier>();
    final activeProj = appState.activeProject;

    return Column(
      children: [
        // Explorer Panel Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Row(
            children: [
              Icon(Icons.account_tree_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                activeProj?.name ?? 'Explorer',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                onPressed: () => _showNewFolderDialog(
                    context, activeProj?.path ?? '/workspace/mobile-ide'),
                tooltip: 'New Root Folder',
              ),
              IconButton(
                icon: const Icon(Icons.note_add_outlined, size: 18),
                onPressed: () => _showNewFileDialog(
                    context, activeProj?.path ?? '/workspace/mobile-ide'),
                tooltip: 'New Root File',
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _refreshTree,
                tooltip: 'Refresh Tree',
              ),
            ],
          ),
        ),

        // File Tree Viewport
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _rootNode == null || _rootNode!.children.isEmpty
                  ? Center(
                      child: Text(
                        'Empty Directory',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    )
                  : SingleChildScrollView(
                      child: _buildFileTreeNode(context, _rootNode!, 0),
                    ),
        ),
      ],
    );
  }
}
