import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import 'package:tmjapp/api/auth_api.dart';

class ProfilePhotoBottomSheet extends StatefulWidget {
  final void Function(File image) onImageSelected;
  final String token;
  final String userId;

  const ProfilePhotoBottomSheet({
    Key? key,
    required this.onImageSelected,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfilePhotoBottomSheet> createState() =>
      _ProfilePhotoBottomSheetState();
}

class _ProfilePhotoBottomSheetState extends State<ProfilePhotoBottomSheet> {
  File? profileImage;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxHeight: 400,
      maxWidth: 400,
    );
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.white, // Alterado para fundo branco
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adicione uma foto de perfil',
                style: GoogleFonts.roboto(
                  fontSize: Dimensions.extraLargeTextSize,
                  fontWeight: FontWeight.bold,
                  color: CustomColor.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? Icon(Icons.person, size: 48, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label:
                        Text('Câmera', style: TextStyle(color: Colors.white)),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: Icon(Icons.photo, color: Colors.white),
                    label:
                        Text('Galeria', style: TextStyle(color: Colors.white)),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: profileImage == null
                    ? null
                    : () async {
                        try {
                          final String base64Image = "data:image/jpeg;base64," +
                              base64Encode(profileImage!.readAsBytesSync());
                          final response = await Authapi().updateProfilePhoto(
                              base64Image, widget.token, widget.userId);

                          if (response.ok) {
                            widget.onImageSelected(profileImage!);
                            Navigator.of(context).pop();
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Erro'),
                                content:
                                    Text('Erro ao atualizar foto de perfil.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Erro'),
                              content: Text('Erro ao conectar ao servidor.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                child: Text('Confirmar', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Text(
                'Por segurança, é obrigatório cadastrar uma foto de perfil.',
                style: TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
