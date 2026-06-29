import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_option.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class RideConfirmSheet extends StatelessWidget {
  const RideConfirmSheet({
    super.key,
    required this.origin,
    required this.destination,
    required this.isLoading,
    required this.products,
    required this.selectedProductIndex,
    required this.selectedPaymentMethod,
    required this.paymentOptions,
    required this.onSelectProduct,
    required this.onSelectPaymentMethod,
    required this.onEditOrigin,
    required this.onEditDestination,
    required this.onRequestRide,
  });

  final RouteLocation origin;
  final RouteLocation destination;
  final bool isLoading;
  final List<RideProduct> products;
  final int selectedProductIndex;
  final RidePaymentMethod selectedPaymentMethod;
  final List<RidePaymentOption> paymentOptions;
  final ValueChanged<int> onSelectProduct;
  final ValueChanged<RidePaymentMethod> onSelectPaymentMethod;
  final VoidCallback onEditOrigin;
  final VoidCallback onEditDestination;
  final VoidCallback onRequestRide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      // Limitando a altura máxima do BottomSheet para 60% da tela
      // Assim o mapa e o topo nunca irão desaparecer!
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.60,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      // Retiramos o SingleChildScrollView global e usamos uma Column principal
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cabeçalho Fixo (Tracejado + Título)
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ESCOLHA SEU VEÍCULO',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),

          // 2. Área Rolável (Apenas os veículos)
          // O Flexible permite que a lista ocupe o espaço restante sem quebrar a tela
          Flexible(
            child: SingleChildScrollView(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: products.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;
                        final isSelected = index == selectedProductIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => onSelectProduct(index),
                            child: Ink(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFEA580C)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFF1F5F9)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _vehicleIconFor(product.name),
                                      color: const Color(0xFF334155),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.etaLabel} • ${product.subtitle}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'R\$ ${product.estimatedPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),

          // 3. Rodapé Fixo (Forma de pagamento + Botão Solicitar)
          // Estes itens nunca mais sumirão da tela
          const SizedBox(height: 12),
          _PaymentCard(
            selectedPaymentMethod: selectedPaymentMethod,
            paymentOptions: paymentOptions,
            onSelectPaymentMethod: onSelectPaymentMethod,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed:
                  isLoading || selectedProductIndex < 0 ? null : onRequestRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC92D7A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'SOLICITAR TMJ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _vehicleIconFor(String productName) {
    final normalized = productName.toLowerCase();
    if (normalized.contains('moto') || normalized.contains('motorcycle')) {
      return Icons.two_wheeler;
    }
    if (normalized.contains('comfort')) {
      return Icons.airport_shuttle_rounded;
    }
    if (normalized.contains('black')) {
      return Icons.electric_car_rounded;
    }
    return Icons.directions_car_rounded;
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.selectedPaymentMethod,
    required this.paymentOptions,
    required this.onSelectPaymentMethod,
  });

  final RidePaymentMethod selectedPaymentMethod;
  final List<RidePaymentOption> paymentOptions;
  final ValueChanged<RidePaymentMethod> onSelectPaymentMethod;

  // Função auxiliar para garantir o nome caso a opção não venha da API
  String _getFallbackLabel(RidePaymentMethod method) {
    switch (method) {
      case RidePaymentMethod.pix:
        return 'Pix';
      case RidePaymentMethod.cash:
        return 'Dinheiro';
      case RidePaymentMethod.card:
        return 'Cartão';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = paymentOptions
        .where((option) => option.method == selectedPaymentMethod)
        .cast<RidePaymentOption?>()
        .firstWhere(
          (option) => option != null,
          orElse: () => null,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              _iconForMethod(selectedPaymentMethod),
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              // Pega o nome da API, se não existir, usa a nossa função de segurança
              selectedOption?.label ?? _getFallbackLabel(selectedPaymentMethod),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          PopupMenuButton<RidePaymentMethod>(
            initialValue: selectedPaymentMethod,
            onSelected: onSelectPaymentMethod,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) {
              // 1. Mapeia as opções que já vieram
              final items = paymentOptions
                  .map(
                    (option) => PopupMenuItem<RidePaymentMethod>(
                      value: option.method,
                      child: Row(
                        children: [
                          Icon(
                            _iconForMethod(option.method),
                            size: 18,
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              option.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList();

              // 2. Verifica se a opção "Dinheiro" já existe na lista
              final hasCash = paymentOptions
                  .any((opt) => opt.method == RidePaymentMethod.cash);

              // 3. Se não existir, injetamos ela manualmente no menu!
              if (!hasCash) {
                items.add(
                  PopupMenuItem<RidePaymentMethod>(
                    value: RidePaymentMethod.cash,
                    child: Row(
                      children: [
                        Icon(
                          _iconForMethod(RidePaymentMethod.cash),
                          size: 18,
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Dinheiro',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'Alterar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEA580C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForMethod(RidePaymentMethod method) {
    switch (method) {
      case RidePaymentMethod.pix:
        return Icons.pix_rounded;
      case RidePaymentMethod.cash:
        return Icons.payments_rounded;
      case RidePaymentMethod.card:
        return Icons.credit_card_rounded;
    }
  }
}
