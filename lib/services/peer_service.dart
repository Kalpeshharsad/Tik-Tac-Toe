import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:peerdart/peerdart.dart';

enum PeerStatus { idle, hosting, connecting, connected }

class PeerService extends ChangeNotifier {
  static final PeerService _instance = PeerService._internal();
  factory PeerService() => _instance;
  PeerService._internal();

  Peer? _peer;
  DataConnection? _connection;

  PeerStatus status = PeerStatus.idle;
  String? currentRoomCode;
  String? opponentUsername;

  // Callbacks to notify game board
  void Function(Map<String, dynamic> data)? onDataReceived;
  void Function()? onConnectionEstablished;
  void Function()? onConnectionLost;

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void startHosting(String myUsername) {
    if (status != PeerStatus.idle) return;
    status = PeerStatus.hosting;
    currentRoomCode = _generateRoomCode();
    notifyListeners();

    _peer = Peer(id: "kinetic-$currentRoomCode");

    _peer!.on("connection").listen((dynamic event) {
      _connection = event as DataConnection;
      _setupConnectionListeners(_connection!, myUsername);
    });
  }

  void joinRoom(String myUsername, String roomCode) {
    if (status != PeerStatus.idle) return;
    status = PeerStatus.connecting;
    notifyListeners();

    _peer = Peer();

    _peer!.on("open").listen((dynamic id) {
      _connection = _peer!.connect("kinetic-$roomCode");
      _setupConnectionListeners(_connection!, myUsername);
    });
  }

  void _setupConnectionListeners(DataConnection conn, String myUsername) {
    conn.on("open").listen((dynamic _) {
      status = PeerStatus.connected;
      notifyListeners();
      
      // Let the other peer know our username
      _sendInternalMessage({"type": "init", "username": myUsername});
    });

    conn.on("data").listen((dynamic data) {
      final String jsonStr = data as String;
      final payload = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (payload['type'] == 'init') {
        opponentUsername = payload['username'] as String;
        notifyListeners();
        
        // Host might need to send back their username too
        if (currentRoomCode != null && payload['reply'] != true) {
          _sendInternalMessage({"type": "init", "username": myUsername, "reply": true});
        }

        if (onConnectionEstablished != null) {
          onConnectionEstablished!();
        }
      } else {
        if (onDataReceived != null) {
          onDataReceived!(payload);
        }
      }
    });

    conn.on("close").listen((dynamic _) {
      _handleDisconnect();
    });
    
    conn.on("error").listen((dynamic _) {
      _handleDisconnect();
    });
  }

  void _sendInternalMessage(Map<String, dynamic> payload) {
    if (_connection != null && status == PeerStatus.connected) {
      _connection!.send(jsonEncode(payload));
    }
  }

  void sendMessage(Map<String, dynamic> payload) {
    _sendInternalMessage(payload);
  }

  void _handleDisconnect() {
    status = PeerStatus.idle;
    currentRoomCode = null;
    opponentUsername = null;
    _connection?.close();
    _connection = null;
    notifyListeners();
    if (onConnectionLost != null) onConnectionLost!();
  }

  void stopAll() {
    _handleDisconnect();
    _peer?.dispose();
    _peer = null;
  }
}
