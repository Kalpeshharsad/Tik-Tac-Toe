import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:peerdart/peerdart.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';

enum PeerStatus { idle, connecting, connected }

class PeerService extends ChangeNotifier {
  static final PeerService _instance = PeerService._internal();
  factory PeerService() => _instance;
  PeerService._internal();

  Peer? _peer;
  DataConnection? _connection;

  PeerStatus status = PeerStatus.idle;
  String? opponentUsername;

  // Invite System State
  Map<String, DataConnection> pendingInvites = {};
  String? outgoingInviteTo;
  bool isHost = false;

  // Callbacks to notify game board
  void Function(Map<String, dynamic> data)? onDataReceived;
  void Function()? onConnectionEstablished;
  void Function()? onConnectionLost;

  String get myPeerId => 'kinetic_${AuthService().currentUserId}';

  // Initialize peer on app start or login
  void initPeer() {
    if (_peer != null) return;
    if (AuthService().currentUserId == null) return;

    _peer = Peer(id: myPeerId);

    _peer!.on("open").listen((dynamic id) {
      debugPrint('PeerJS Open: $id');
    });

    // Handle incoming connections (Invites)
    _peer!.on("connection").listen((dynamic event) {
      // If we are already in a match, ignore
      if (status == PeerStatus.connected) return;

      final conn = event as DataConnection;
      
      conn.on("open").listen((dynamic _) {
        // Wait for them to send the 'invite' payload
      });

      conn.on("data").listen((dynamic data) {
        _handleIncomingDataSafely(data, conn);
      });
      
      conn.on("close").listen((dynamic _) {
        if (pendingInvites.values.contains(conn)) {
          pendingInvites.removeWhere((key, value) => value == conn);
          notifyListeners();
        }
      });
    });

    _peer!.on("error").listen((dynamic err) {
      debugPrint('PeerJS Error: $err');
      _handleDisconnect();
    });
  }

  void _handleIncomingDataSafely(dynamic data, DataConnection sourceConn) {
    Map<String, dynamic> payload;
    try {
      if (data is String) {
        payload = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map) {
        payload = Map<String, dynamic>.from(data);
      } else {
        return;
      }
    } catch (e) {
      return;
    }

    // Is it an invite?
    if (payload['type'] == 'invite') {
      final senderId = payload['from'] as String?;
      if (senderId != null) {
        pendingInvites[senderId] = sourceConn;
        notifyListeners();
      }
    } 
    // Is it an invite response?
    else if (payload['type'] == 'invite_response') {
      final accepted = payload['accepted'] == true;
      if (accepted) {
        opponentUsername = outgoingInviteTo;
        outgoingInviteTo = null;
        status = PeerStatus.connected;
        _setupActiveConnectionListeners(_connection!);
        notifyListeners();
        if (onConnectionEstablished != null) onConnectionEstablished!();
      } else {
        // Declined
        outgoingInviteTo = null;
        _connection?.close();
        _connection = null;
        status = PeerStatus.idle;
        notifyListeners();
      }
    }
    // Is it game data during an active match?
    else if (status == PeerStatus.connected) {
      if (onDataReceived != null) onDataReceived!(payload);
    }
  }

  // --- Invite Actions ---

  void sendInvite(String targetUserId) {
    if (_peer == null) return;
    outgoingInviteTo = targetUserId;
    isHost = true;
    status = PeerStatus.connecting;
    notifyListeners();

    _connection = _peer!.connect('kinetic_$targetUserId');
    
    _connection!.on("open").listen((dynamic _) {
      _connection!.send(jsonEncode({
        "type": "invite",
        "from": AuthService().currentUserId,
      }));
    });

    _connection!.on("data").listen((dynamic data) {
      _handleIncomingDataSafely(data, _connection!);
    });

    _connection!.on("close").listen((dynamic _) {
       _handleDisconnect();
    });
    _connection!.on("error").listen((dynamic _) {
       _handleDisconnect();
    });
  }

  void acceptInvite(String senderId) {
    if (!pendingInvites.containsKey(senderId)) return;
    
    final conn = pendingInvites[senderId]!;
    conn.send(jsonEncode({
      "type": "invite_response", 
      "accepted": true
    }));
    
    isHost = false;
    opponentUsername = senderId;
    pendingInvites.clear();
    status = PeerStatus.connected;
    _connection = conn;
    
    _setupActiveConnectionListeners(conn);
    notifyListeners();
    
    if (onConnectionEstablished != null) onConnectionEstablished!();
  }

  void declineInvite(String senderId) {
    if (!pendingInvites.containsKey(senderId)) return;
    final conn = pendingInvites[senderId]!;
    
    conn.send(jsonEncode({
      "type": "invite_response", 
      "accepted": false
    }));
    
    conn.close();
    pendingInvites.remove(senderId);
    notifyListeners();
  }

  // --- Active Match Data ---

  void _setupActiveConnectionListeners(DataConnection conn) {
    // Override general listeners with active match listeners if needed, 
    // but we already mapped incoming data to onDataReceived in _handleIncomingDataSafely
    
    conn.on("close").listen((dynamic _) {
      _handleDisconnect();
    });
    conn.on("error").listen((dynamic _) {
      _handleDisconnect();
    });
  }

  void sendMessage(Map<String, dynamic> payload) {
    if (_connection != null && status == PeerStatus.connected) {
      _connection!.send(jsonEncode(payload));
    }
  }

  void _handleDisconnect() {
    status = PeerStatus.idle;
    opponentUsername = null;
    pendingInvites.clear();
    outgoingInviteTo = null;
    isHost = false;
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

  void endMatch() {
    if (_connection != null) {
      _connection!.close();
    }
    _handleDisconnect();
  }
}
