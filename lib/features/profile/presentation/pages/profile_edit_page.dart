import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';
import 'package:tmjapp/features/profile/presentation/controllers/profile_controller.dart';

class ProfileEditPage extends StatefulWidget {
  final ProfileDetails profile;

  const ProfileEditPage({super.key, required this.profile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e telefone são obrigatórios.')),
      );
      return;
    }
    Navigator.of(context).pop({'name': name, 'phone': phone});
  }

  // 👇 LÓGICA CENTRALIZADA AQUI
  Future<void> _handleChangePhoto() async {
    // 1. Vai até a tela de escolher a opção e espera a resposta ('camera' ou 'gallery')
    final String? sourceString =
        await Navigator.of(context).pushNamed(AppRoutes.changePhoto) as String?;
    if (sourceString == null) return;

    // 2. Transforma a string no ImageSource do ImagePicker
    final source =
        sourceString == 'camera' ? ImageSource.camera : ImageSource.gallery;

    // 3. Abre a câmera ou galeria
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    // 4. Pega o Controller que JÁ EXISTE nesta tela e faz o upload
    if (!mounted) return;
    final controller = context.read<ProfileController>();
    await controller.updatePhoto(File(pickedFile.path));

    // 5. Exibe os resultados
    if (!mounted) return;
    if (controller.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.state.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos o estado atualizado do controller
    final controllerState = context.watch<ProfileController>().state;
    // Se tivermos um perfil no estado usamos ele, senão o perfil inicial passado ao widget
    final currentProfile = controllerState.profile ?? widget.profile;
    final isSaving = controllerState.isSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _onSave,
            child: Text(
              'Salvar',
              style: GoogleFonts.plusJakartaSans(
                color: isSaving ? Colors.grey : const Color(0xFFC92D7A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFFE4EB),
                      // Exibe a foto da rede se existir
                      backgroundImage:
                          (currentProfile.profilePhotoUrl ?? '').isNotEmpty
                              ? NetworkImage(currentProfile.profilePhotoUrl!)
                              : null,
                      // Exibe as iniciais caso não tenha foto
                      child: (currentProfile.profilePhotoUrl ?? '').isEmpty
                          ? Text(
                              currentProfile.initials,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF9D174D),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC92D7A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: isSaving ? null : _handleChangePhoto,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFFC92D7A)),
                          )
                        : Text(
                            'Alterar Foto',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFC92D7A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Nome Completo',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                enabled: !isSaving,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  hintText: 'Nome completo',
                ),
              ),
              const SizedBox(height: 14),
              Text('Número de Telefone',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !isSaving,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  hintText: 'Telefone',
                  prefixText: '+55 ',
                ),
              ),
              const SizedBox(height: 14),
              Text('E-mail',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: currentProfile.email),
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
