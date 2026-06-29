import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideLoadingBottomSheet extends StatelessWidget {
  final String from;
  final String to;
  final double price;
  final String payment;
  final Future<bool> Function() onCancel;
  final Future<bool> Function() onClose;

  const RideLoadingBottomSheet({
    Key? key,
    required this.from,
    required this.to,
    required this.price,
    required this.payment,
    required this.onCancel,
    required this.onClose,
  }) : super(key: key);

  Future<void> _showCancelAlert(
      BuildContext context, Future<bool> Function() action) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar viagem'),
        content: const Text('Deseja cancelar a viagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    if (shouldCancel == true) {
      await action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          await _showCancelAlert(context, onClose);
          // Não fecha automaticamente, espera retorno do backend
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.55,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Viagem solicitada',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Procurando um motorista parceiro perto de você',
                    style:
                        GoogleFonts.roboto(fontSize: 15, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Informações da viagem',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vá até o local de partida: $from',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 2,
                                height: 24,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.square, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                to,
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Text('R\$ ${price.toStringAsFixed(2)}',
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 16),
                      Text(payment,
                          style: GoogleFonts.roboto(color: Colors.black54)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Alterar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _showCancelAlert(context, onCancel);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar viagem',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _showCancelAlert(context, onClose);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
