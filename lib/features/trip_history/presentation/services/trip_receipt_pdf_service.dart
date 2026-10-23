import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tmjapp/features/trip_history/domain/entities/trip_history_item.dart';

class TripReceiptPdfService {
  const TripReceiptPdfService();

  Future<File> create(TripHistoryItem item) async {
    final document = pw.Document();
    final price = item.price.toStringAsFixed(2).replaceAll('.', ',');

    document.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Recibo de viagem - TMJ',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            _row('Viagem', item.title),
            _row('Data', item.dateLabel),
            _row('Status', item.status),
            pw.Divider(),
            _row('Origem', '${item.originTitle} - ${item.originSubtitle}'),
            _row(
              'Destino',
              '${item.destinationTitle} - ${item.destinationSubtitle}',
            ),
            pw.SizedBox(height: 8),
            _row('Motorista', item.driverName),
            _row('Veículo', '${item.vehicle} - ${item.plate}'),
            _row('Distância', item.distanceLabel),
            _row('Duração', item.durationLabel),
            pw.Divider(),
            _row('Pagamento', item.paymentLabel),
            _row('Total', 'R\$ $price'),
            _row('Código da viagem', item.id),
          ],
        ),
      ),
    );

    final directory = await getTemporaryDirectory();
    final safeId = item.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${directory.path}/recibo-viagem-$safeId.pdf');
    await file.writeAsBytes(await document.save(), flush: true);
    return file;
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
