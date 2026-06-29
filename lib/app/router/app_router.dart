import 'package:flutter/material.dart';

import 'package:tmjapp/features/auth/presentation/pages/sign_in_page.dart';
import 'package:tmjapp/features/forgot_password/presentation/pages/forgot_password_page.dart';
import 'package:tmjapp/features/home/presentation/pages/dashboard_page.dart';
import 'package:tmjapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:tmjapp/features/payments/presentation/pages/payments_page.dart';
import 'package:tmjapp/features/profile/presentation/pages/profile_page.dart';
import 'package:tmjapp/features/sign_up/presentation/pages/sign_up_page.dart';
import 'package:tmjapp/features/splash/presentation/pages/splash_page.dart';
import 'package:tmjapp/features/trip_history/presentation/pages/trip_history_page.dart';
import 'package:tmjapp/features/sos/presentation/pages/sos_page.dart';
import 'package:tmjapp/features/payments/presentation/pages/pix_payment_page.dart';
import 'package:tmjapp/features/payments/presentation/pages/pix_payment_processing_page.dart';
import 'package:tmjapp/features/payments/presentation/pages/pix_payment_not_identified_page.dart';
import 'package:tmjapp/features/favorites/presentation/add_favorite_page.dart';
import 'package:tmjapp/features/profile/presentation/pages/help_support_page.dart';
import 'package:tmjapp/features/profile/presentation/pages/profile_change_photo_page.dart';
import 'package:tmjapp/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:tmjapp/features/profile/presentation/pages/saved_addresses_page.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';
import 'package:tmjapp/features/profile/presentation/pages/security_and_terms_page.dart';
import 'package:tmjapp/features/profile/presentation/pages/promotions_coupons_page.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';
  static const dashboard = '/home/dashboard';
  static const payments = '/payments';
  static const profile = '/profile';
  static const tripHistory = '/trips/history';
  static const sos = '/sos';
  static const pixPayment = '/payments/pix';
  static const pixPaymentProcessing = '/payments/pix/processing';
  static const pixPaymentNotIdentified = '/payments/pix/not-identified';
  static const savedAddresses = '/profile/saved-addresses';
  static const helpSupport = '/profile/help-support';
  static const editProfile = '/profile/edit';
  static const changePhoto = '/profile/change-photo';
  static const addFavoriteAddress = '/favorites/add-address';
  static const securityAndTerms = '/security-and-terms';
  static const promotionsAndCoupons = '/promotions-coupons';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );
      case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
          settings: settings,
        );
      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
          settings: settings,
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
      case AppRoutes.payments:
        return MaterialPageRoute(
          builder: (_) => const PaymentsPage(),
          settings: settings,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case AppRoutes.tripHistory:
        return MaterialPageRoute(
          builder: (_) => const TripHistoryPage(),
          settings: settings,
        );
      case AppRoutes.sos:
        return MaterialPageRoute(
          builder: (_) => const SosPage(),
          settings: settings,
        );
      case AppRoutes.savedAddresses:
        return MaterialPageRoute(
          builder: (_) => const SavedAddressesPage(),
          settings: settings,
        );
      case AppRoutes.helpSupport:
        return MaterialPageRoute(
          builder: (_) => const HelpSupportPage(),
          settings: settings,
        );
      case AppRoutes.editProfile:
        final profile = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => ProfileEditPage(profile: profile),
          settings: settings,
        );
      case AppRoutes.changePhoto:
        return MaterialPageRoute(
          builder: (_) => const ProfileChangePhotoPage(),
          settings: settings,
        );

      // 👇 AQUI: Adicionado os cases para as novas rotas 👇
      case AppRoutes.securityAndTerms:
        return MaterialPageRoute(
          builder: (_) => const SecurityAndTermsPage(),
          settings: settings,
        );
      case AppRoutes.promotionsAndCoupons:
        return MaterialPageRoute(
          builder: (_) => const PromotionsCouponsPage(),
          settings: settings,
        );

      case AppRoutes.pixPayment:
        final args = settings.arguments;
        double amount = 0.0;
        bool paymentValidated = false;
        RideRequestArgs? rideArgs;

        if (args is double) {
          amount = args;
        } else if (args is Map<String, dynamic>) {
          amount = (args['amount'] as double?) ?? 0.0;
          paymentValidated = (args['validated'] as bool?) ?? false;
          rideArgs = args['rideArgs'] as RideRequestArgs?;
        }

        return MaterialPageRoute(
          builder: (_) => PixPaymentPage(
            amount: amount,
            paymentValidated: paymentValidated,
            rideArgs: rideArgs,
          ),
          settings: settings,
        );
      case AppRoutes.pixPaymentProcessing:
        final args = settings.arguments;
        double amount = 0.0;
        RideRequestArgs? rideArgs;
        bool paymentIdentified = true;

        if (args is double) {
          amount = args;
        } else if (args is Map<String, dynamic>) {
          amount = (args['amount'] as double?) ?? 0.0;
          rideArgs = args['rideArgs'] as RideRequestArgs?;
          paymentIdentified = (args['paymentIdentified'] as bool?) ?? true;
        }

        return MaterialPageRoute(
          builder: (_) => PixPaymentProcessingPage(
            amount: amount,
            rideArgs: rideArgs,
            paymentIdentified: paymentIdentified,
          ),
          settings: settings,
        );
      case AppRoutes.pixPaymentNotIdentified:
        return MaterialPageRoute(
          builder: (_) => const PixPaymentNotIdentifiedPage(),
          settings: settings,
        );
      case AppRoutes.addFavoriteAddress:
        return MaterialPageRoute(
          builder: (_) => const AddFavoriteAddressPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
    }
  }
}
