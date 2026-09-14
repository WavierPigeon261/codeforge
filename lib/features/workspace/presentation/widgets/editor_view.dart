import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../file_explorer/services/file_system_service.dart';

class EditorView extends StatefulWidget {
  final String filePath;
  final String initialContent;

  const EditorView({
    super.key,
    required this.filePath,
    required this.initialContent,
  });

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late TextEditingController _textController;
  late ScrollController _scrollController;
  late ScrollController _lineNumberScrollController;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialContent);
    _scrollController = ScrollController();
    _lineNumberScrollController = ScrollController();

    _textController.addListener(() {
      if (!_isDirty && _textController.text != widget.initialContent) {
        setState(() {
          _isDirty = true;
        });
      }
    });

    _scrollController.addListener(() {
      if (_lineNumberScrollController.hasClients &&
          _lineNumberScrollController.offset != _scrollController.offset) {
        _lineNumberScrollController.jumpTo(_scrollController.offset);
      }
    });
  }

  @override
  void didUpdateWidget(covariant EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath ||
        oldWidget.initialContent != widget.initialContent) {
      _textController.text = widget.initialContent;
      _isDirty = false;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }

  Future<void> _saveFile() async {
    await FileSystemService.writeFile(widget.filePath, _textController.text);
    if (!mounted) return;
    context.read<AppStateNotifier>().openFile(widget.filePath, _textController.text);
    setState(() {
      _isDirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${widget.filePath.split('/').last} successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = widget.filePath.split('/').last;
    final lines = _textController.text.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;

    return Column(
      children: [
        // Editor Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Row(
            children: [
              Icon(
                Icons.code_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                fileName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (_isDirty) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${lines.length} lines',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.save_outlined,
                  size: 18,
                  color: _isDirty ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
                onPressed: _isDirty ? _saveFile : null,
                tooltip: 'Save (Ctrl+S)',
              ),
            ],
          ),
        ),

        // Editor Body with Line Numbers & Monospace TextField
        Expanded(
          child: Container(
            color: theme.colorScheme.surface,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Numbers Column
                Container(
                  width: 44,
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: ListView.builder(
                    controller: _lineNumberScrollController,
                    itemCount: lineCount,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 20,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.outline.withOpacity(0.6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),

                // Main Text Input Area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(8.0),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
