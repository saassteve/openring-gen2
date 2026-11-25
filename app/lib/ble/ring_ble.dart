import 'package:flutter/services.dart';

final class RingBle {
  const RingBle();

  static const _methods = MethodChannel('ringconn/ble');
  static const _events = EventChannel('ringconn/ble/events');

  Stream<Map<Object?, Object?>> get events =>
      _events.receiveBroadcastStream().cast<Map<Object?, Object?>>();

  Future<void> startScan() => _methods.invokeMethod<void>('startScan');
  Future<void> stopScan() => _methods.invokeMethod<void>('stopScan');
  Future<void> connect(String id) =>
      _methods.invokeMethod<void>('connect', {'id': id});
  Future<void> subscribe() => _methods.invokeMethod<void>('subscribe');
  Future<void> write(Uint8List bytes) =>
      _methods.invokeMethod<void>('write', {'bytes': bytes});
  Future<void> disconnect() => _methods.invokeMethod<void>('disconnect');
  Future<void> setHighPriority(bool enabled) async {
    try {
      await _methods.invokeMethod<bool>('setHighPriority', {'enabled': enabled});
    } on MissingPluginException {
      // Optional optimization implemented on Android.
    }
  }
}
