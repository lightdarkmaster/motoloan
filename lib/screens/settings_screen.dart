import 'package:flutter/material.dart';
import 'package:motoloan/screens/about_app_screen.dart';
import '../app_theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppThemeController controller;

  static const accents = <int>[
    // Original colors
    0xFF20A875, // Emerald Green
    0xFF4C8DFF, // Royal Blue
    0xFF9B72CF, // Lavender Purple
    0xFFE08A36, // Burnt Orange
    0xFFE05D75, // Rose Pink
    0xFF19A6A6, // Teal
    // Additional colors
    0xFF00B8D9, // Cyan
    0xFF3F51B5, // Indigo
    0xFF673AB7, // Deep Purple
    0xFF8E44AD, // Amethyst
    0xFFEC407A, // Hot Pink
    0xFFE53935, // Cherry Red
    0xFFFF7043, // Coral
    0xFFFFA000, // Amber
    0xFF8D6E63, // Brown
    0xFF78909C, // Blue Grey
    0xFF7CB342, // Lime Green
    0xFF26A69A, // Sea Green
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(
            'APPEARANCE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Choose how MotoLoan looks on your device.',
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 14),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: 350,
                    child: SegmentedButton<AppThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: AppThemeMode.system,
                          icon: Icon(Icons.settings_suggest),
                          label: Text('System'),
                        ),
                        ButtonSegment(
                          value: AppThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: AppThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                      ],

                      selected: {controller.mode},

                      onSelectionChanged: (value) {
                        controller.setMode(value.first);
                      },

                      showSelectedIcon: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accent color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Customize buttons, highlights, and active controls.',
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: accents.map((value) {
                      final selected = controller.accentValue == value;

                      return InkWell(
                        onTap: () => controller.setAccent(value),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Color(value),
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          Text(
            'ABOUT',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.two_wheeler),
                  title: Text('MotoLoan'),
                  subtitle: Text('Motorcycle loan tracker'),
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                ListTile(
                  leading: const Icon(Icons.phone_android_rounded),
                  title: const Text('App version'),
                  subtitle: const Text('1.0.0'),
                  trailing: Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About the App'),
                  subtitle: const Text('App information and developer details'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutAppScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
