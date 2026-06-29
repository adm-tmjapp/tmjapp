import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Para o switch no estilo iOS se desejar, mas usaremos o nativo do Material
import 'package:google_fonts/google_fonts.dart';

// Cores baseadas na sua paleta do ProfilePage
const Color _primaryPink = Color(0xFFC92D7A);
const Color _bgPinkLight = Color(0xFFFCE7F3);
const Color _bgLight = Color(0xFFF8FAFC);
const Color _textDark = Color(0xFF1D2939);
const Color _textMedium = Color(0xFF344054);
const Color _textLight = Color(0xFF667085);

class SecurityAndTermsPage extends StatefulWidget {
  const SecurityAndTermsPage({super.key});

  @override
  State<SecurityAndTermsPage> createState() => _SecurityAndTermsPageState();
}

class _SecurityAndTermsPageState extends State<SecurityAndTermsPage> {
  // Simulando um estado para a biometria
  bool _useBiometrics = true;

  void _showNotImplementedMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ficará disponível em breve.'),
        backgroundColor: _textMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Segurança e Termos',
          style: GoogleFonts.plusJakartaSans(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // --- SEÇÃO: SEGURANÇA ---
            const _SectionTitle('SEGURANÇA DA CONTA'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _MenuTile(
                    label: 'Alterar Senha',
                    icon: Icons.lock_outline_rounded,
                    onTap: () =>
                        _showNotImplementedMessage('Alteração de senha'),
                  ),
                  const _CustomDivider(),
                  _ToggleTile(
                    label: 'Acesso com Biometria',
                    icon: Icons.fingerprint_rounded,
                    value: _useBiometrics,
                    onChanged: (val) {
                      setState(() {
                        _useBiometrics = val;
                      });
                    },
                  ),
                  const _CustomDivider(),
                  _MenuTile(
                    label: 'Sessões Ativas',
                    icon: Icons.devices_rounded,
                    onTap: () => _showNotImplementedMessage('Sessões ativas'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- SEÇÃO: TERMOS E PRIVACIDADE ---
            const _SectionTitle('LEGAL E PRIVACIDADE'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _MenuTile(
                    label: 'Termos de Uso',
                    icon: Icons.description_outlined,
                    onTap: () => _showNotImplementedMessage('Termos de Uso'),
                  ),
                  const _CustomDivider(),
                  _MenuTile(
                    label: 'Política de Privacidade',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () =>
                        _showNotImplementedMessage('Política de Privacidade'),
                  ),
                  const _CustomDivider(),
                  _MenuTile(
                    label: 'Licenças de Software',
                    icon: Icons.code_rounded,
                    onTap: () => _showNotImplementedMessage('Licenças'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: _textLight,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _bgPinkLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryPink, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textMedium,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _bgPinkLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryPink, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textMedium,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _primaryPink,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 68, // Alinha a linha divisória com o texto, ignorando o ícone
    );
  }
}
