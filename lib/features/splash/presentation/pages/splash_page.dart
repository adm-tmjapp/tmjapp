import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:tmjapp/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:tmjapp/features/splash/domain/entities/splash_destination.dart';
import 'package:tmjapp/features/splash/domain/usecases/resolve_splash_destination_usecase.dart';
import 'package:tmjapp/features/splash/presentation/controllers/splash_controller.dart';
import 'package:tmjapp/features/splash/presentation/controllers/splash_state.dart';
import 'package:tmjapp/features/splash/presentation/widgets/tmj_splash_brand.dart';
import 'package:tmjapp/features/splash/presentation/widgets/tmj_splash_progress.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController(
      ResolveSplashDestinationUseCase(
        SplashRepositoryImpl(
          SplashLocalDataSource(),
        ),
      ),
    )..addListener(_handleStateChanged);

    _controller.initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleStateChanged)
      ..dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    final destination = _controller.state.destination;
    if (!mounted || destination == null) {
      return;
    }

    final routeName = switch (destination) {
      SplashDestination.dashboard => AppRoutes.dashboard,
      SplashDestination.signIn => AppRoutes.signIn,
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return _SplashPageBody(state: _controller.state);
            },
          ),
        ),
      ),
    );
  }
}

class _SplashPageBody extends StatelessWidget {
  const _SplashPageBody({
    required this.state,
  });

  final SplashState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Spacer(flex: 2),
        const AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 600),
          child: TmjSplashBrand(),
        ),
        const Spacer(flex: 3),
        TmjSplashProgress(progress: state.progress),
        const SizedBox(height: 20),
        Text(
          state.isLoading ? 'Preparando sua experiência...' : 'Redirecionando...',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF9CA3AF),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Powered by TMJ Technology',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFB6BAC4),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
