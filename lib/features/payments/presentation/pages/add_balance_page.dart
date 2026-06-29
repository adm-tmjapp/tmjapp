import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👇 AQUI: Import necessário para o input formatter
import 'package:google_fonts/google_fonts.dart';

// Cores baseadas no seu layout
const Color _primaryPink = Color(0xFFB1226B);
const Color _textDark = Color(0xFF1D2939);
const Color _textLight = Color(0xFF667085);
const Color _bgLight = Color(0xFFF9FAFB);

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({super.key});

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  final TextEditingController _amountController = TextEditingController();
  double _currentAmount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setPredefinedAmount(double amount) {
    setState(() {
      _currentAmount = amount;
      // 👇 AQUI: Formatamos o valor para exibir com separador de milhar (se houver) e vírgula
      String formatted = amount.toStringAsFixed(2).replaceAll('.', ',');
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      List<String> parts = formatted.split(',');
      String wholeNumber =
          parts[0].replaceAllMapped(reg, (Match match) => '${match[1]}.');

      _amountController.text = '$wholeNumber,${parts[1]}';
    });
  }

  void _onAmountChanged(String value) {
    // 👇 AQUI: Pega apenas os números digitados para converter em double
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      if (cleanValue.isEmpty) {
        _currentAmount = 0.0;
      } else {
        // Divide por 100 para aplicar as duas casas decimais no valor real
        _currentAmount = double.parse(cleanValue) / 100;
      }
    });
  }

  void _onContinue() {
    if (_currentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um valor válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop(_currentAmount);
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
          'Adicionar Saldo',
          style: GoogleFonts.plusJakartaSans(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qual valor você deseja adicionar?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha um valor abaixo ou digite um valor personalizado.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textLight,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de digitação de valor
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'R\$',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        // 👇 AQUI: Alterado para number e adicionado o input formatter
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        onChanged: _onAmountChanged,
                        cursorColor: _primaryPink,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _primaryPink,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0,00',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botões de valores rápidos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAmountButton(
                    amount: 20.0,
                    isSelected: _currentAmount == 20.0,
                    onTap: () => _setPredefinedAmount(20.0),
                  ),
                  _QuickAmountButton(
                    amount: 50.0,
                    isSelected: _currentAmount == 50.0,
                    onTap: () => _setPredefinedAmount(50.0),
                  ),
                  _QuickAmountButton(
                    amount: 100.0,
                    isSelected: _currentAmount == 100.0,
                    onTap: () => _setPredefinedAmount(100.0),
                  ),
                  _QuickAmountButton(
                    amount: 200.0,
                    isSelected: _currentAmount == 200.0,
                    onTap: () => _setPredefinedAmount(200.0),
                  ),
                ],
              ),

              const Spacer(),

              // Botão Continuar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentAmount > 0 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPink,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _currentAmount > 0
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
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

// Widget privado para os botões de atalho (R$ 20, R$ 50, etc)
class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryPink : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          '+ ${amount.toInt()}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }
}

// 👇 AQUI: Novo formatador customizado para Moeda (BRL)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove qualquer caractere que não seja número
    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Transforma em double simulando a digitação da direita para a esquerda
    double value = double.parse(numbers) / 100;

    // Converte para o padrão Brasileiro (vírgula para decimais)
    String newText = value.toStringAsFixed(2).replaceAll('.', ',');

    // Adiciona o ponto separador de milhares (Ex: 1.000,00)
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    List<String> parts = newText.split(',');
    String wholeNumber =
        parts[0].replaceAllMapped(reg, (Match match) => '${match[1]}.');

    newText = '$wholeNumber,${parts[1]}';

    return newValue.copyWith(
      text: newText,
      // Mantém o cursor sempre no final do input
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
