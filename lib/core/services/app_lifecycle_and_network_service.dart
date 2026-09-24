import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:flutter/widgets.dart';

class AppLifecycleAndNetworkService with WidgetsBindingObserver {
  AppLifecycleAndNetworkService._();
  static final AppLifecycleAndNetworkService instance = AppLifecycleAndNetworkService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String _lastNetworkStatus = '';

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _initNetworkMonitoring();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    logInfo('AppLifecycleState = ${state.name}');
  }

  void _initNetworkMonitoring() {
    _connectivity.checkConnectivity().then(_handleConnectivityChange);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final String networkInfo = _formatConnectivityResults(results);

    // Hindari log ganda jika statusnya identik
    if (networkInfo == _lastNetworkStatus) return;
    _lastNetworkStatus = networkInfo;

    logInfo(networkInfo);
  }

  String _formatConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'Network = disconnected';
    }

    final types = results
        .where((r) => r != ConnectivityResult.none)
        .map((r) {
          switch (r) {
            case ConnectivityResult.wifi:
              return 'wifi';
            case ConnectivityResult.mobile:
              return 'mobile';
            case ConnectivityResult.ethernet:
              return 'ethernet';
            case ConnectivityResult.vpn:
              return 'vpn';
            case ConnectivityResult.bluetooth:
              return 'bluetooth';
            case ConnectivityResult.other:
              return 'other';
            case ConnectivityResult.none:
              return 'disconnected';
            case ConnectivityResult.satellite:
              return 'satellite';
          }
        })
        .toSet()
        .join(', ');

    return 'Network = ${types.isNotEmpty ? types : "connected"}';
  }
}
