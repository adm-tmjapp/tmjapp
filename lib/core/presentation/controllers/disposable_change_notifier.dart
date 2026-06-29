import 'package:flutter/foundation.dart';

mixin DisposableChangeNotifier on ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
