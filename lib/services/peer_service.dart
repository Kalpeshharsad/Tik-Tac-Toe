import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:peerdart/peerdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Saved contacts (persisted)
  List<String> savedContacts = [];

  // Callbacks to notify game board
  void Function(Map<String, dynamic> data)? onDataReceived;
  void Function()? onConnectionEstablished;
  void Function()? onConnectionLost;

  String get myPeerId => 'kinetic_${AuthService().currentUserId}';

  // ── Contacts Persistence ──────────────────────────────────────────────────

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    savedContacts = prefs.getStringList('saved_contacts') ?? [];
    notifyListeners();
  }

  Future<void> _saveContact(String userId) async {
    if (!savedContacts.contains(userId)) {
      savedContacts.add(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_contacts', savedContacts);
      notifyListeners();
    }
  }

  Future<void> removeContact(String userId) async {
    savedContacts.remove(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_contacts', savedContacts);
    notifyListeners();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  void initPeer() {
    if (_peer != null) return;
    if (AuthService().currentUserId == null) return;

    _peer = Peer(id: myPeerId);

    _peer!.on("open").listen((dynamic id) {
      debugPrint('PeerJS Open: $id');
    });

    // Handle incoming connections (invites from other players)
    _peer!.on("connection").listen((dynamic event) {
      // If already in a match, ignore new connections
      if (status == PeerStatus.connected) return;

      final conn = event as DataConnection;

      // Single data listener per incoming connection
      conn.on("data").listen((dynamic data) {
        _handleIncomingData(data, conn);
      });

      conn.on("close").listen((dynamic _) {
        // Remove from pending if it was a pending invite
        pendingInvites.removeWhere((key, value) => value == conn);
        notifyListeners();
      });
    });

    _peer!.on("error").listen((dynamic err) {
      debugPrint('PeerJS Error: $err');
      _triggerDisconnect();
    });

    // Load saved contacts
    loadContacts();
  }

  // ── Data Handling ─────────────────────────────────────────────────────────

  void _handleIncomingData(dynamic raw, DataConnection sourceConn) {
    Map<String, dynamic> payload;
    try {
      if (raw is String) {
        payload = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map) {
        payload = Map<String, dynamic>.from(raw);
      } else if (raw is List) {
        // On some platforms (iOS -> Android), text arrives as byte arrays
        try {
          final str = utf8.decode(raw.cast<int>());
          payload = jsonDecode(str) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('PeerJS binary decode error: $e, raw: $raw');
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      debugPrint('PeerJS data parse error: $e');
      return;
    }

    final type = payload['type'] as String?;

    if (type == 'invite') {
      // Incoming invite: store in pending
      final senderId = payload['from'] as String?;
      if (senderId != null && status != PeerStatus.connected) {
        pendingInvites[senderId] = sourceConn;
        notifyListeners();
      }
    } else if (type == 'invite_response') {
      // Our invite was accepted or declined
      final accepted = payload['accepted'] == true;
      if (accepted) {
        opponentUsername = outgoingInviteTo;
        _saveContact(outgoingInviteTo!);
        outgoingInviteTo = null;
        status = PeerStatus.connected;
        notifyListeners();
        if (onConnectionEstablished != null) onConnectionEstablished!();
      } else {
        outgoingInviteTo = null;
        _connection?.close();
        _connection = null;
        status = PeerStatus.idle;
        notifyListeners();
      }
    } else if (status == PeerStatus.connected) {
      // Active match data — route to GameState
      if (onDataReceived != null) onDataReceived!(payload);
    }
  }

  // ── Invite Actions ────────────────────────────────────────────────────────

  void sendInvite(String targetUserId) {
    if (_peer == null) return;
    outgoingInviteTo = targetUserId;
    isHost = true;
    status = PeerStatus.connecting;
    notifyListeners();

    _connection = _peer!.connect('kinetic_$targetUserId');

    _connection!.on("open").listen((dynamic _) {
      debugPrint('PeerService: connection opened');
      _connection!.send(jsonEncode({
        "type": "invite",
        "from": AuthService().currentUserId,
      }));
    });

    // Store reference to connection before attaching listener
    final conn = _connection;
    if (conn != null) {
      // Single data listener on outgoing connection
      conn.on("data").listen((dynamic data) {
        debugPrint('PeerService: data received on invite connection: $data');
        _handleIncomingData(data, conn);
      });

      conn.on("close").listen((dynamic _) {
        debugPrint('PeerService: connection closed');
        if (status != PeerStatus.idle) _triggerDisconnect();
      });

      conn.on("error").listen((dynamic _) {
        debugPrint('PeerService: connection error');
        if (status != PeerStatus.idle) _triggerDisconnect();
      });
    }
  }

  void acceptInvite(String senderId) {
    if (!pendingInvites.containsKey(senderId)) return;

    final conn = pendingInvites[senderId]!;

    conn.send(jsonEncode({
      "type": "invite_response",
      "accepted": true,
    }));

    isHost = false;
    opponentUsername = senderId;
    _saveContact(senderId);

    // Close all other pending invites
    for (final entry in pendingInvites.entries) {
      if (entry.key != senderId) {
        entry.value.send(jsonEncode({"type": "invite_response", "accepted": false}));
        entry.value.close();
      }
    }
    pendingInvites.clear();

    status = PeerStatus.connected;
    _connection = conn;

    // Add disconnect listener to the accepted connection
    conn.on("close").listen((dynamic _) {
      if (status != PeerStatus.idle) _triggerDisconnect();
    });
    conn.on("error").listen((dynamic _) {
      if (status != PeerStatus.idle) _triggerDisconnect();
    });

    notifyListeners();
    if (onConnectionEstablished != null) onConnectionEstablished!();
  }

  void declineInvite(String senderId) {
    if (!pendingInvites.containsKey(senderId)) return;
    final conn = pendingInvites[senderId]!;
    conn.send(jsonEncode({"type": "invite_response", "accepted": false}));
    conn.close();
    pendingInvites.remove(senderId);
    notifyListeners();
  }

  // ── Active Match ──────────────────────────────────────────────────────────

  void sendMessage(Map<String, dynamic> payload) {
    if (_connection != null && status == PeerStatus.connected) {
      try {
        _connection!.send(jsonEncode(payload));
      } catch (e) {
        debugPrint('PeerJS sendMessage error: $e');
      }
    } else {
      debugPrint('PeerJS sendMessage: skipped - connection=${_connection != null}, status=$status');
    }
  }

  void _triggerDisconnect() {
    if (status == PeerStatus.idle) return; // Already disconnected, don't fire twice
    status = PeerStatus.idle;
    opponentUsername = null;
    pendingInvites.clear();
    outgoingInviteTo = null;
    isHost = false;
    _connection = null;
    notifyListeners();
    if (onConnectionLost != null) onConnectionLost!();
  }

  /// End only the active match — keep peer alive for future invites
  void endMatch({bool broadcast = true}) {
    if (broadcast) {
      sendMessage({'type': 'quit'});
    }
    final wasConnected = status == PeerStatus.connected;
    if (wasConnected && _connection != null) {
      try { _connection!.close(); } catch (_) {}
    }
    status = PeerStatus.idle;
    opponentUsername = null;
    pendingInvites.clear();
    outgoingInviteTo = null;
    isHost = false;
    _connection = null;
    // Do NOT fire onConnectionLost here — caller is intentionally ending
    notifyListeners();
  }

  /// Full teardown — destroys peer socket
  void stopAll() {
    endMatch();
    _peer?.dispose();
    _peer = null;
  }
}
