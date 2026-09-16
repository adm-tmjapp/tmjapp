class PixPaymentData {
  const PixPaymentData({
    this.paymentId,
    this.status,
    this.expiresAt,
    this.copyPasteCode,
    this.encodedImage,
  });

  final String? paymentId;
  final String? status;
  final DateTime? expiresAt;
  final String? copyPasteCode;
  final String? encodedImage;

  bool get isPaid => isPixPaidStatus(status);
  bool get isClosed => isPixClosedStatus(status);

  factory PixPaymentData.fromJson(Map<String, dynamic> json) {
    final root = _unwrap(json);
    final pix = _asMap(
      root['pix'] ?? root['qrCode'] ?? root['qr_code'] ?? root['pixData'],
    );

    return PixPaymentData(
      paymentId: _firstText(root, const [
        'paymentId',
        'payment_id',
        'id',
        'transactionId',
      ]),
      status: _firstText(root, const [
        'status',
        'paymentStatus',
        'payment_status',
      ]),
      expiresAt: DateTime.tryParse(
        _firstText(root, const [
              'paymentExpiresAt',
              'expiresAt',
              'expires_at',
              'expirationDate',
            ]) ??
            '',
      ),
      copyPasteCode: _firstText(pix, const [
            'payload',
            'copyPaste',
            'copy_paste',
            'copyPasteCode',
            'emv',
            'code',
            'qrCode',
          ]) ??
          _firstText(root, const [
            'pixCode',
            'pix_code',
            'copyPasteCode',
            'copy_paste',
          ]),
      encodedImage: _firstText(pix, const [
            'encodedImage',
            'encoded_image',
            'qrCodeImage',
            'qr_code_image',
            'base64',
          ]) ??
          _firstText(root, const [
            'encodedImage',
            'encoded_image',
            'qrCodeImage',
          ]),
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final payment = _asMap(data['payment'] ?? json['payment']);
    return <String, dynamic>{...json, ...data, ...payment};
  }
}

bool isPixPaidStatus(String? status) {
  return const {
    'PAID',
    'APPROVED',
    'COMPLETED',
    'CONFIRMED',
    'RECEIVED',
    'SUCCESS',
    'SUCCEEDED',
  }.contains(_normalize(status));
}

bool isPixClosedStatus(String? status) {
  return const {
    'CANCELED',
    'CANCELLED',
    'FAILED',
    'EXPIRED',
    'REJECTED',
  }.contains(_normalize(status));
}

String? normalizedPixBase64(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  final comma = text.indexOf(',');
  if (text.startsWith('data:') && comma >= 0) {
    return text.substring(comma + 1).replaceAll(RegExp(r'\s'), '');
  }
  return text.replaceAll(RegExp(r'\s'), '');
}

String _normalize(String? value) =>
    (value ?? '').trim().toUpperCase().replaceAll(RegExp(r'[\s-]+'), '_');

Map<String, dynamic> _asMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

String? _firstText(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty && value != 'null') return value;
  }
  return null;
}
