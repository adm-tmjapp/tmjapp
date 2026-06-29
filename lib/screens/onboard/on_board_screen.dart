import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/auth/sign_in_screen.dart';
import 'package:tmjapp/utils/strings.dart';
import 'data.dart';

class OnBoardScreen extends StatefulWidget {
  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  /* static Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.value(false);
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();

      return false;
    }
    return true;
  }*/

  @override
  void initState() {
    // handleLocationPermission();
    super.initState();
  }

  int totalPages = OnBoardingItems.loadOnboardItem().length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF6FB),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.black87),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Onboarding',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentPage + 1}/$totalPages',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final oi = OnBoardingItems.loadOnboardItem()[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 220,
                              width: 260,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x19000000),
                                    blurRadius: 20,
                                    offset: Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFD83C8D),
                                        Color(0xFFB3165D),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.verified_user_rounded,
                                      size: 56,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 32,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shield_rounded,
                                  color: const Color(0xFFC92D7A),
                                  size: 18,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 24,
                              right: 36,
                              child: Container(
                                width: 94,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Text(
                                oi.title ?? "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                oi.subTitle ?? "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  totalPages,
                                  (i) => AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    height: 8,
                                    width: i == _currentPage ? 18 : 8,
                                    decoration: BoxDecoration(
                                      color: i == _currentPage
                                          ? const Color(0xFFC92D7A)
                                          : const Color(0xFFD1D5DB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Container(
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 16,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Pular',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC92D7A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (_currentPage == totalPages - 1) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => SignInScreen(),
                                  ),
                                );
                              } else {
                                _pageController.nextPage(
                                  duration:
                                      const Duration(milliseconds: 260),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  _currentPage == totalPages - 1
                                      ? Strings.getStarted
                                      : 'Próximo',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
