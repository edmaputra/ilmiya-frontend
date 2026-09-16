import 'package:flutter/material.dart';
import 'ilmiya_app_shell.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;

  const AdaptiveScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return IlmiyaAppShell(body: body);
  }
}
