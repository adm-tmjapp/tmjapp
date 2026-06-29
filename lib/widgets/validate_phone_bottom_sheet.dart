import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/api/auth_api.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class ValidatePhoneBottomSheet extends StatefulWidget {
  final String token;
  final String userId;
  final String phone;

  const ValidatePhoneBottomSheet({
    Key? key,
    required this.token,
    required this.userId,
    required this.phone,
  }) : super(key: key);

  @override
  State<ValidatePhoneBottomSheet> createState() =>
      _ValidatePhoneBottomSheetState();
}

class _ValidatePhoneBottomSheetState extends State<ValidatePhoneBottomSheet> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String updatedPhone = "";
  bool canResendCode = true;
  int remainingTime = 60;
  bool isEditingPhone = false;

  @override
  void initState() {
    super.initState();
    updatedPhone = widget.phone;
  }

  void startResendCodeTimer() {
    setState(() {
      canResendCode = false;
      remainingTime = 60;
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime--;
      });
      if (remainingTime <= 0) {
        timer.cancel();
        setState(() {
          canResendCode = true;
        });
      }
    });
  }

  Future<void> _sendNewCode() async {
    startResendCodeTimer();
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Authapi().sendNewCode(widget.token, widget.userId);
      if (response.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código reenviado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reenviar código.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _verifyPhone() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Authapi().verifyPhone(
        widget.token,
        widget.userId,
        codeController.text,
      );
      if (response.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Número verificado com sucesso!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar número.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changePhone() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Authapi().changePhone(
        widget.token,
        widget.userId,
        updatedPhone,
      );

      if (response.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Número de telefone alterado com sucesso!')),
        );
        setState(() {
          isEditingPhone = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar o número de telefone.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao servidor.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldCancel = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Cancelar validação'),
              content: Text(
                'Deseja realmente cancelar a validação? Este é um passo importante para a segurança dos usuários na plataforma.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Sim'),
                ),
              ],
            );
          },
        );
        if (shouldCancel == true) {
          Navigator.of(context)
              .pop(false); // Retorna para a tela anterior com erro de validação
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: Dimensions.marginSize,
              right: Dimensions.marginSize,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  Dimensions.marginSize,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Digite o código recebido',
                  style: GoogleFonts.roboto(
                    fontSize: Dimensions.extraLargeTextSize,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    TextFormField(
                      initialValue: updatedPhone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Número de celular',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius),
                        ),
                      ),
                      enabled: isEditingPhone,
                      onChanged: (value) {
                        setState(() {
                          updatedPhone = value;
                        });
                      },
                    ),
                    if (!isEditingPhone)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEditingPhone = true;
                            });
                          },
                          child: Icon(
                            Icons.edit,
                            color: CustomColor.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                if (isEditingPhone)
                  Column(
                    children: [
                      const SizedBox(height: Dimensions.heightSize),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await _changePhone();
                                setState(() {
                                  isEditingPhone = false;
                                  isLoading = false;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Salvar',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                const SizedBox(height: Dimensions.heightSize * 2),
                if (!isEditingPhone)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: CustomColor.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            // Adicione lógica para capturar o código
                          },
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: Dimensions.heightSize * 2),
                if (!isEditingPhone)
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            await _verifyPhone();
                            setState(() {
                              isLoading = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Validar número',
                            style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(height: Dimensions.heightSize),
                if (!isEditingPhone)
                  Column(
                    children: [
                      TextButton(
                        onPressed:
                            isLoading || !canResendCode ? null : _sendNewCode,
                        child: Text('Reenviar código',
                            style:
                                TextStyle(color: CustomColor.secondaryColor)),
                      ),
                      if (!canResendCode)
                        Text(
                          '$remainingTime segundos',
                          style: TextStyle(color: CustomColor.secondaryColor),
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
