import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../application/subscription_service.dart';
import 'subscription_state.dart';

class SubscriptionController extends ChangeNotifier {
  SubscriptionController({required SubscriptionService service}) : _service = service;

  final SubscriptionService _service;
  SubscriptionState _state = const SubscriptionState();
  StreamSubscription? _subscription;

  SubscriptionState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _service.initialize();
      final plan = await _service.loadPlan();
      final status = await _service.getStatus();

      _subscription?.cancel();
      _subscription = _service.watchStatus().listen((nextStatus) {
        _state = _state.copyWith(status: nextStatus, clearError: true);
        notifyListeners();
      });

      _state = _state.copyWith(plan: plan, status: status, isLoading: false, clearError: true);
    } catch (_) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'No fue posible inicializar las suscripciones.',
      );
    }

    notifyListeners();
  }

  Future<void> purchase() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final bool started = await _service.purchaseMonthlyPlan();
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: started ? null : 'No se pudo iniciar la compra en este momento.',
      );
    } catch (_) {
      _state = _state.copyWith(isLoading: false, errorMessage: 'Error al procesar la compra.');
    }

    notifyListeners();
  }

  Future<void> restore() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _service.restorePurchases();
      _state = _state.copyWith(isLoading: false, clearError: true);
    } catch (_) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron restaurar las compras.',
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
