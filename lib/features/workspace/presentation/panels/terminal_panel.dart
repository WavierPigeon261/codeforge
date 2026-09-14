import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import '../../../terminal/services/terminal_backend_service.dart';

class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  late final Terminal _terminal;
  late final TerminalBackendService _backendService;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(
      maxLines: 2000,
    );
    _backendService = TerminalBackendService(
      terminal: _terminal,
      prootStoragePath: '/data/data/com.example.mobile_ide/files/proot_env',
      currentWorkingDirectory: '/workspace/mobile-ide',
    );
  }

  @override
  void dispose() {
    _backendService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Terminal Header Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Row(
            children: [
              Icon(Icons.terminal, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Embedded Linux PTY',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Chip(
                visualDensity: VisualDensity.compact,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                label: const Text('Proot Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
              IconButton(
                icon: const Icon(Icons.clear_all, size: 18),
                onPressed: () {
                  _terminal.write('\x1B[2J\x1B[H');
                },
                tooltip: 'Clear Output',
              ),
            ],
          ),
        ),

        // Terminal Viewport
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(8.0),
            child: TerminalView(
              _terminal,
              backgroundOpacity: 1.0,
              autofocus: true,
            ),
          ),
        ),
      ],
    );
  }
}
