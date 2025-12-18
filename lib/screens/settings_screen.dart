import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 20),
            Text(
              'Настройки',
              // ИСПРАВЛЕНО: headline4 -> headlineMedium
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Здесь будут находиться настройки приложения.',
              // ИСПРАВЛЕНО: bodyText1 -> bodyLarge
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
