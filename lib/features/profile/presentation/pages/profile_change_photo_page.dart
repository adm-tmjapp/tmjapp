import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileChangePhotoPage extends StatelessWidget {
  const ProfileChangePhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFC92D7A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Trocar Foto',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFC92D7A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 196,
                height: 196,
                decoration: BoxDecoration(
                  color: const Color(0xFFEACED5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 6),
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt_rounded,
                      size: 88, color: Color(0xFFBB0F6A)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Escolha uma foto bem iluminada onde seu rosto esteja nítido e centralizado.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),
            // BOTÃO CÂMERA
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop('camera'), // DEVOLVE 'camera'
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              label: Text('Tirar Foto',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC92D7A),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            // BOTÃO GALERIA
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop('gallery'), // DEVOLVE 'gallery'
              icon: const Icon(Icons.image_outlined, color: Color(0xFFC92D7A)),
              label: Text('Escolher da Galeria',
                  style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFC92D7A),
                      fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC92D7A)),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
