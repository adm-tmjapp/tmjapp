import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tmjapp/features/friend_ride/data/datasources/friend_driver_remote_datasource.dart';
import 'package:tmjapp/features/friend_ride/domain/entities/friend_driver.dart';

class FriendDriverSearchPage extends StatefulWidget {
  const FriendDriverSearchPage({super.key});

  @override
  State<FriendDriverSearchPage> createState() => _FriendDriverSearchPageState();
}

class _FriendDriverSearchPageState extends State<FriendDriverSearchPage> {
  static const _pink = Color(0xFFC92D7A);
  final _phoneController = TextEditingController();
  final _dataSource = FriendDriverRemoteDataSource();
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  FriendDriver? _driver;
  String? _error;
  bool _isSearching = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final phone = _phoneMask.getUnmaskedText();
    if (phone.length != 11) {
      setState(() => _error = 'Informe um telefone com DDD.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _error = null;
      _driver = null;
    });
    try {
      final driver = await _dataSource.findActiveDriverByPhone(phone);
      if (!mounted) return;
      setState(() {
        _driver = driver;
        _error = driver == null
            ? 'Motorista não encontrado ou indisponível no momento.'
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() =>
          _error = 'Não foi possível buscar o motorista. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          'Corrida Amigo',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_alt_outlined, color: _pink),
            ),
            const SizedBox(height: 20),
            Text(
              'Encontre seu motorista amigo',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1D2939),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite o telefone cadastrado do motorista. Ele precisa estar disponível para receber a corrida.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF667085),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[_phoneMask],
              onChanged: (_) => setState(() {
                _driver = null;
                _error = null;
              }),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                labelText: 'Telefone do motorista',
                labelStyle: const TextStyle(color: Colors.black),
                hintText: '(00) 00000-0000',
                prefixIcon: const Icon(Icons.phone_outlined, color: _pink),
                filled: true,
                fillColor: Colors.white,
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _pink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(
                  _isSearching ? 'Buscando...' : 'Buscar motorista',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (_driver != null) ...[
              const SizedBox(height: 24),
              _DriverResultCard(
                driver: _driver!,
                onContinue: () => Navigator.of(context).pop(_driver),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DriverResultCard extends StatelessWidget {
  const _DriverResultCard({required this.driver, required this.onContinue});

  final FriendDriver driver;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final vehicle = [driver.vehicle, driver.licensePlate]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(' • ');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1D1E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFFDE8F1),
                child: Icon(Icons.person_rounded, color: Color(0xFFC92D7A)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    if (vehicle.isNotEmpty) Text(vehicle),
                    if (driver.rating != null)
                      Text('★ ${driver.rating!.toStringAsFixed(1)}'),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC92D7A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continuar com este motorista',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
