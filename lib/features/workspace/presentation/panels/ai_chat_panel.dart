import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../ai_chat/services/ai_service.dart';

class AiChatPanel extends StatefulWidget {
  const AiChatPanel({super.key});

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  final List<AiResponse> _chatHistory = [
    AiResponse(
      providerName: 'Antigravity CLI',
      content: 'Hello! I am your AI assistant connected to OpenCode / Antigravity CLI.\nAsk me to construct Flutter widgets, refactor code, or run shell scripts.',
      timestamp: DateTime.now(),
    ),
  ];

  Future<void> _handleSendPrompt(AppStateNotifier appState) async {
    final text = _promptController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    setState(() {
      _chatHistory.add(
        AiResponse(
          providerName: 'You',
          content: text,
          timestamp: DateTime.now(),
        ),
      );
      _promptController.clear();
      _isGenerating = true;
    });

    _scrollToBottom();

    final response = await AiService.processPrompt(
      userPrompt: text,
      provider: appState.selectedAiProvider,
      activeFilePath: appState.selectedFilePath,
      activeFileContent: appState.activeFileContent,
    );

    if (!mounted) return;

    setState(() {
      _chatHistory.add(response);
      _isGenerating = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getProviderName(AiProvider provider) {
    switch (provider) {
      case AiProvider.antigravityCli:
        return 'Antigravity CLI';
      case AiProvider.openCode:
        return 'OpenCode Engine';
      case AiProvider.geminiPro:
        return 'Gemini Pro';
      case AiProvider.claudeSonnet:
        return 'Claude Sonnet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppStateNotifier>();

    return Column(
      children: [
        // Header with AI Provider Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<AiProvider>(
                value: appState.selectedAiProvider,
                isDense: true,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(12),
                items: AiProvider.values.map((provider) {
                  return DropdownMenuItem<AiProvider>(
                    value: provider,
                    child: Text(
                      _getProviderName(provider),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newProvider) {
                  if (newProvider != null) {
                    appState.setAiProvider(newProvider);
                  }
                },
              ),
            ],
          ),
        ),

        // Message List View
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12.0),
            itemCount: _chatHistory.length,
            itemBuilder: (context, index) {
              final msg = _chatHistory[index];
              final isUser = msg.providerName == 'You';

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                        bottomLeft: !isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.providerName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUser
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUser
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (msg.codeSnippet != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      msg.codeLanguage ?? 'code',
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 10,
                                          fontFamily: 'monospace'),
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                                ClipboardData(text: msg.codeSnippet!));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text('Copied code to clipboard!')),
                                            );
                                          },
                                          child: const Icon(Icons.copy,
                                              size: 14, color: Colors.white70),
                                        ),
                                        const SizedBox(width: 8),
                                        if (appState.selectedFilePath != null)
                                          InkWell(
                                            onTap: () {
                                              appState.openFile(
                                                appState.selectedFilePath!,
                                                msg.codeSnippet!,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('Applied code to open editor!')),
                                              );
                                            },
                                            child: const Icon(Icons.input_rounded,
                                                size: 14, color: Colors.lightGreenAccent),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white24, height: 8),
                                Text(
                                  msg.codeSnippet!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (_isGenerating)
          const LinearProgressIndicator(minHeight: 2),

        // Prompt Input Field
        Container(
          padding: const EdgeInsets.all(8.0),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ask ${_getProviderName(appState.selectedAiProvider)}...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _handleSendPrompt(appState),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send_rounded),
                onPressed: _isGenerating ? null : () => _handleSendPrompt(appState),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
