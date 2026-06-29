import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Cores baseadas no seu layout
const Color _primaryPink = Color(0xFFB1226B);
const Color _textDark = Color(0xFF1D2939);
const Color _textLight = Color(0xFF667085);
const Color _bgLight = Color(0xFFF9FAFB);

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Aqui você integraria com o seu Controller para criptografar/salvar o cartão
      // Exemplo: _controller.saveCreditCard(number, name, expiry, cvv);

      // Simulando sucesso e retornando para a tela anterior
      Navigator.of(context).pop(true);
    }
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
          'Adicionar Cartão',
          style: GoogleFonts.plusJakartaSans(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                'Detalhes do Cartão',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Insira as informações do seu cartão de crédito ou débito para salvá-lo com segurança.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Número do Cartão
              _CustomTextField(
                controller: _cardNumberController,
                label: 'Número do Cartão',
                hint: '0000 0000 0000 0000',
                keyboardType: TextInputType.number,
                maxLength: 19, // 16 dígitos + 3 espaços
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.length < 19) {
                    return 'Insira um número de cartão válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nome do Titular
              _CustomTextField(
                controller: _nameController,
                label: 'Nome do Titular',
                hint: 'NOME NO CARTÃO',
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o nome do titular';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Validade e CVV na mesma linha
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CustomTextField(
                      controller: _expiryController,
                      label: 'Validade',
                      hint: 'MM/AA',
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryDateFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.length < 5) {
                          return 'Data inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CustomTextField(
                      controller: _cvvController,
                      label: 'CVV',
                      hint: '123',
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return 'CVV inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Salvar Cartão',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Badge de Segurança
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      color: _textLight, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Seus dados são criptografados e seguros.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES E FORMATADORES
// ============================================================================

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLength: maxLength,
          cursorColor: _primaryPink,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
          decoration: InputDecoration(
            counterText: "", // Esconde o contador do maxLength
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryPink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// Adiciona um espaço a cada 4 dígitos
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Adiciona uma barra "/" após o mês (MM/AA)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
