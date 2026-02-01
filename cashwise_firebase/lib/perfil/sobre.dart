// sobre_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  // Funções auxiliares para abrir links externos
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Não foi possível abrir o link: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
        backgroundColor: const Color(0xFF10a5c6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo/Ícone do App
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF10a5c6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 60,
                color: Color(0xFF10a5c6),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gestão Financeira Jovem',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Versão 1.0.0', // Atualize dinamicamente se possível (package_info_plus)
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Descrição Curta
            const Text(
              'Nosso aplicativo foi criado para ajudar jovens e adolescentes a aprenderem sobre dinheiro de forma divertida e prática, transformando mesadas e pequenos ganhos em grandes hábitos financeiros.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Menu de Links
            _buildLinkItem(
              icon: Icons.shield_outlined,
              title: 'Política de Privacidade',
              onTap: () => _launchUrl('https://seusite.com/privacidade'),
            ),
            _buildLinkItem(
              icon: Icons.description_outlined,
              title: 'Termos de Uso',
              onTap: () => _launchUrl('https://seusite.com/termos'),
            ),
            _buildLinkItem(
              icon: Icons.help_outline,
              title: 'Ajuda e Perguntas Frequentes (FAQ)',
              onTap: () => _launchUrl('https://seusite.com/ajuda'),
            ),
            _buildLinkItem(
              icon: Icons.star_border,
              title: 'Avalie-nos na Loja de Aplicativos',
              onTap: () {
                // TODO: Link específico da App Store/Google Play
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirecionando para a loja...'),
                    backgroundColor: Color(0xFF10a5c6),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // Redes Sociais
            const Text(
              'Siga a gente!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  icon: Icons.camera_alt_outlined,
                  onTap: () => _launchUrl('https://instagram.com/seuapp'),
                  tooltip: 'Instagram',
                ),
                _buildSocialIcon(
                  icon: Icons.video_library_outlined,
                  onTap: () => _launchUrl('https://tiktok.com/@seuapp'),
                  tooltip: 'TikTok',
                ),
                _buildSocialIcon(
                  icon: Icons.email_outlined,
                  onTap: () => _launchUrl('mailto:suporte@seuapp.com'),
                  tooltip: 'E-mail de Suporte',
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Direitos Autorais
            Text(
              '© ${DateTime.now().year} Gestão Financeira Jovem. Todos os direitos reservados.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF10a5c6)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IconButton(
        icon: Icon(icon, size: 30, color: const Color(0xFF10a5c6)),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }
}