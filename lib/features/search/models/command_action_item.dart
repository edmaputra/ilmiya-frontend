import 'package:flutter/material.dart';

class CommandActionItem {
  final String title;
  final String group;
  final IconData icon;
  final String? subtitle;
  final VoidCallback onSelect;

  const CommandActionItem({
    required this.title,
    required this.group,
    required this.icon,
    this.subtitle,
    required this.onSelect,
  });
}
