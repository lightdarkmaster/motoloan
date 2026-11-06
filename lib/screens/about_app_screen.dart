import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('About the App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // App Logo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.two_wheeler_rounded,
                size: 65,
                color: accentColor,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'MotoLoan',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Motorcycle Loan Tracker',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            Text('Version 1.0.0', style: theme.textTheme.bodySmall),

            const SizedBox(height: 30),

            _buildSection(
              context,
              title: 'About MotoLoan',
              description:
                  'MotoLoan is a motorcycle loan tracking application '
                  'designed to help users monitor their motorcycle '
                  'financing, record payments, and keep track of their '
                  'remaining loan balance.',
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              title: 'App Features',
              description:
                  '• Motorcycle loan information management\n'
                  '• Loan principal and down payment tracking\n'
                  '• Payment recording and history\n'
                  '• Remaining balance monitoring\n'
                  '• Duplicate monthly payment prevention\n'
                  '• Customizable application themes',
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              title: 'Developer Information',
              description:
                  'Developer: Christian Barbosa\n'
                  'Application: MotoLoan\n'
                  'Platform: Flutter\n'
                  'Database: SQLite\n'
                  'Development Year: 2026',
            ),

            const SizedBox(height: 30),

            Text(
              'MotoLoan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage your motorcycle loan with ease.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
