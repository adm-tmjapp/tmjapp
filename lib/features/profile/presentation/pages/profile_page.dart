import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_bottom_navigation.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';
import 'package:tmjapp/features/profile/presentation/controllers/profile_controller.dart';
import 'package:tmjapp/features/profile/presentation/pages/profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(
      localDataSource: ProfileLocalDataSource(),
      remoteDataSource: ProfileRemoteDataSource(),
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DESATIVAÇÃO DE CONTA ---

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede que feche clicando fora do modal
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirmar Desativação',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D2939),
            ),
          ),
          content: Text(
            'Tem certeza que deseja desativar sua conta no TMJ?',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF475467)),
          ),
          actions: [
            // Ação caso clique em "Não" (fecha o modal e permanece na tela)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Não',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF667085),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Ação caso clique em "Sim"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92D20),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
                _handleDeletionFlow(); // Inicia o fluxo de exclusão
              },
              child: Text(
                'Sim',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDeletionFlow() {
    // Exibe a mensagem de direcionamento ao suporte
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 4),
        backgroundColor: Color(0xFF344054),
        content: Text(
          'Você será direcionado ao atendimento de suporte técnico para continuidade da solicitação.',
        ),
      ),
    );

    // Aguarda 2 segundos e redireciona para a tela de ajuda/suporte
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.helpSupport);
    });
  }

  // --- FIM DA LÓGICA DE DESATIVAÇÃO ---

  Future<void> _openEditProfile(ProfileDetails profile) async {
    // Envolve ProfileEditPage com ChangeNotifierProvider para disponibilizar o controller
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _controller,
          child: ProfileEditPage(profile: profile),
        ),
      ),
    );

    if (result is Map<String, String>) {
      await _controller.updateProfile(
        name: result['name'] ?? profile.name,
        phone: result['phone'] ?? profile.phone,
      );

      if (!mounted) return;

      final error = _controller.state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Perfil atualizado com sucesso.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Meus Pagamentos', AppRoutes.payments, Icons.wallet_rounded),
      ('Histórico de Viagens', AppRoutes.tripHistory, Icons.history_rounded),
      (
        'Endereços Salvos',
        AppRoutes.savedAddresses,
        Icons.location_on_outlined
      ),
      (
        'Promoções e Cupons',
        AppRoutes.promotionsAndCoupons,
        Icons.local_offer_outlined
      ),
      ('Segurança e Termos', AppRoutes.securityAndTerms, Icons.shield_outlined),
      ('Ajuda e Suporte', AppRoutes.helpSupport, Icons.help_outline_rounded),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;
            final profile = state.profile;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _controller.refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      children: [
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 160),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (profile == null)
                          _ErrorState(
                            message: state.errorMessage ??
                                'Não foi possível carregar seu perfil.',
                            onRetry: _controller.refresh,
                          )
                        else ...[
                          Column(
                            children: [
                              Container(
                                width: 92,
                                height: 92,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  profile.initials,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF667085),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                profile.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1D2939),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profile.email.isNotEmpty
                                    ? profile.email
                                    : profile.phone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: state.isSaving
                                    ? null
                                    : () => _openEditProfile(profile),
                                child: Text(
                                  state.isSaving
                                      ? 'Salvando...'
                                      : 'Editar Perfil',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFC92D7A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          ...items.map(
                            (item) => _ProfileMenuTile(
                              label: item.$1,
                              icon: item.$3,
                              onTap: () {
                                if (item.$2 == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${item.$1} entra como subfluxo.')),
                                  );
                                  return;
                                }
                                Navigator.of(context).pushNamed(item.$2!);
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                await _controller.signOut();
                                if (!mounted) return;
                                navigator.pushNamedAndRemoveUntil(
                                    AppRoutes.signIn, (_) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF2F4F7),
                                foregroundColor: const Color(0xFF667085),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                'Sair da Conta',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),

                          // BOTÃO DE EXCLUSÃO
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: _showDeleteAccountConfirmation,
                              style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFD92D20)),
                              child: Text(
                                'Desativar minha conta',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'v1.5.0',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF98A2B3),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                HomeBottomNavigation(
                  currentIndex: 3,
                  onTap: (index) => _handleBottomNavigation(context, index),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.tripHistory);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.payments);
        break;
      default:
        break;
    }
  }
}

// --- CLASSES AUXILIARES (IMPORTANTES PARA NÃO DAR ERRO) ---

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 140),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFC92D7A), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF344054),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
          ],
        ),
      ),
    );
  }
}
