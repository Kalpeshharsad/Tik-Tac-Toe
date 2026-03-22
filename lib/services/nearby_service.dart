import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';

enum NearbyStatus { idle, advertising, discovering, connected }

class NearbyService {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();

  final Strategy strategy = Strategy.P2P_STAR;
  String? connectedEndpointId;
  String? connectedEndpointName;
  NearbyStatus status = NearbyStatus.idle;

  // Callbacks for the UI
  void Function(String id, String name)? onEndpointFound;
  void Function(String id)? onEndpointLost;
  void Function(String id, ConnectionInfo info)? onConnectionInitiated;
  void Function(String id)? onConnected;
  void Function(String id)? onDisconnected;
  void Function(Map<String, dynamic> data)? onDataReceived;

  Future<bool> startAdvertising(String username) async {
    try {
      bool a = await Nearby().startAdvertising(
        username,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      if (a) status = NearbyStatus.advertising;
      return a;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startDiscovery(String username) async {
    try {
      bool a = await Nearby().startDiscovery(
        username,
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: (id) => _onEndpointLost(id),
      );
      if (a) status = NearbyStatus.discovering;
      return a;
    } catch (e) {
      return false;
    }
  }

  void stopAll() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    status = NearbyStatus.idle;
  }

  Future<void> invite(String id, String username) async {
    await Nearby().requestConnection(
      username,
      id,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
  }

  Future<void> acceptConnection(String id) async {
    await Nearby().acceptConnection(
      id,
      onPayLoadRecieved: _onPayloadReceived,
    );
  }

  void sendMove(int index) {
    if (connectedEndpointId != null) {
      final data = jsonEncode({'type': 'move', 'index': index});
      Nearby().sendBytesPayload(
          connectedEndpointId!, Uint8List.fromList(data.codeUnits));
    }
  }

  void sendEmoji(String emoji) {
    if (connectedEndpointId != null) {
      final data = jsonEncode({'type': 'emoji', 'emoji': emoji});
      Nearby().sendBytesPayload(
          connectedEndpointId!, Uint8List.fromList(data.codeUnits));
    }
  }

  // Internal Callbacks
  void _onEndpointFound(String id, String name, String serviceId) {
    onEndpointFound?.call(id, name);
  }

  void _onEndpointLost(String? id) {
    if (id != null) onEndpointLost?.call(id);
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    onConnectionInitiated?.call(id, info);
  }

  void _onConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      connectedEndpointId = id;
      this.status = NearbyStatus.connected;
      onConnected?.call(id);
    } else if (status == Status.REJECTED || status == Status.ERROR) {
      this.status = NearbyStatus.idle;
    }
  }

  void _onDisconnected(String id) {
    connectedEndpointId = null;
    status = NearbyStatus.idle;
    onDisconnected?.call(id);
  }

  void _onPayloadReceived(String id, Payload payload) {
    if (payload.type == PayloadType.BYTES) {
      final String str = String.fromCharCodes(payload.bytes!);
      final data = jsonDecode(str) as Map<String, dynamic>;
      onDataReceived?.call(data);
    }
  }
}
