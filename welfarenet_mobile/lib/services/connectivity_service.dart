import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  Timer? _timer;
  bool _isConnected = true;

  void startMonitoring() {
    // Check immediately
    checkConnectivity();

    // Check every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkConnectivity();
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateConnectivity(true);
        return true;
      } else {
        _updateConnectivity(false);
        return false;
      }
    } on SocketException catch (_) {
      _updateConnectivity(false);
      return false;
    } on TimeoutException catch (_) {
      _updateConnectivity(false);
      return false;
    } catch (e) {
      print('Connectivity check error: $e');
      _updateConnectivity(false);
      return false;
    }
  }

  void _updateConnectivity(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(isConnected);
    }
  }

  bool get isConnected => _isConnected;

  void dispose() {
    _timer?.cancel();
    _connectivityController.close();
  }
}

// Widget wrapper to show no internet page when offline
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final Widget? noInternetPage;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.noInternetPage,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _connectivitySubscription;
  bool _isConnected = true;
  bool _showNoInternet = false;

  @override
  void initState() {
    super.initState();
    _connectivityService.startMonitoring();

    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      setState(() {
        _isConnected = isConnected;
        if (!isConnected) {
          // Show no internet page after 2 seconds of no connection
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !_isConnected) {
              setState(() {
                _showNoInternet = true;
              });
            }
          });
        } else {
          _showNoInternet = false;
        }
      });

      // Show snackbar notification
      if (mounted) {
        if (!isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text('No internet connection'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Back online'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _retry() async {
    setState(() {
      _showNoInternet = false;
    });

    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && !_connectivityService.isConnected) {
        setState(() {
          _showNoInternet = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showNoInternet && widget.noInternetPage != null) {
      return widget.noInternetPage!;
    }

    return widget.child;
  }
}
