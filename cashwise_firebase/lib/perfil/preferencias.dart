// preferences_screen.dart
import 'package:flutter/material.dart';

class PreferenciasScreen extends StatefulWidget {
  const PreferenciasScreen({super.key});

  @override
  State<PreferenciasScreen> createState() => _PreferenciasScreenState();
}

class _PreferenciasScreenState extends State<PreferenciasScreen> {
  bool _notificationsEnabled = true;
  String _reportFrequency = 'Mensal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferências'),
        backgroundColor: const Color(0xFF10a5c6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Seção de Notificações e Lembretes ---
            const Text(
              'Notificações e Lembretes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10a5c6),
              ),
            ),
            const Divider(),
            _buildToggleOption(
              title: 'Receber Notificações',
              icon: Icons.notifications_active_outlined,
              value: _notificationsEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _notificationsEnabled = newValue;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newValue 
                        ? '🔔 Notificações ativadas!' 
                        : '🔕 Notificações desativadas',
                    ),
                    backgroundColor: const Color(0xFF10a5c6),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildListTile(
              title: 'Frequência dos Relatórios',
              subtitle: _reportFrequency,
              icon: Icons.bar_chart,
              onTap: () => _showFrequencyDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      secondary: Icon(icon, color: const Color(0xFF10a5c6)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF10a5c6),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF10a5c6)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Frequência dos Relatórios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Semanal', 'Quinzenal', 'Mensal']
                .map(
                  (String value) => RadioListTile<String>(
                    title: Text(value),
                    value: value,
                    groupValue: _reportFrequency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _reportFrequency = newValue!;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Frequência alterada para $newValue'),
                          backgroundColor: const Color(0xFF10a5c6),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}