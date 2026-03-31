import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({required this.title, required this.trailing, super.key});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), trailing: trailing);
  }
}
