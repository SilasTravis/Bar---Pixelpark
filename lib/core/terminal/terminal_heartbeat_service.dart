import 'dart:async';

import 'package:dio/dio.dart';

import '../update/update_failure_log.dart';

/// Tells the backend "this bar PC is alive and runs this version"
/// (`POST /v1/bar/terminal/heartbeat`), so the dashboard's Terminallar page
/// can show which bar PCs are outdated or stuck on a failed update.
///
/// A terminal is one installation, not one cashier: [_terminalId] is
/// generated once per install (see `LocalSource.getTerminalId`), and the
/// backend takes the bar cashier and bar from the token.
///
/// Sent right away on [start], every [_interval] after that, and when a
/// session appears (a bar cashier just signed in). The bar has no offline
/// mode, so unlike the cashier till there is no `mode`/`unsyncedSales` and
/// no mode-flip trigger. Purely diagnostic: every failure is swallowed, and
/// nothing is sent without a session.
class TerminalHeartbeatService {
  TerminalHeartbeatService({
    required this._api,
    required this._hasSession,
    required this._terminalId,
    required this._appVersion,
    required this._lastUpdateFailure,
    required this._hostname,
    required this._osVersion,
    this._sessionChanges,
    this._interval = const Duration(minutes: 2),
  });

  static const String path = '/v1/bar/terminal/heartbeat';

  /// The backend's column limits.
  static const int maxAppVersionLength = 30;
  static const int maxHostnameLength = 100;
  static const int maxOsVersionLength = 200;

  final Dio _api;

  /// Whether a bar cashier is signed in. Without a token the heartbeat
  /// would 401, and the app client's refresh-on-401 ends the session —
  /// resetting the login screen under a cashier who is typing into it (the
  /// same guard as `BackendReleaseSource`).
  final bool Function() _hasSession;

  final String Function() _terminalId;
  final String _appVersion;
  final UpdateFailureRecord? Function() _lastUpdateFailure;
  final String Function() _hostname;
  final String Function() _osVersion;

  /// Fires whenever the stored session may have changed (e.g. the Hive
  /// access-token key). Only a no-session → session transition sends a
  /// beat, so "just signed in" reaches the dashboard without waiting for
  /// the next tick.
  final Stream<void>? _sessionChanges;

  final Duration _interval;

  Timer? _timer;
  StreamSubscription<void>? _sessionSubscription;
  bool _hadSession = false;
  bool _disposed = false;

  /// Idempotent: a second call restarts the timer without doubling the
  /// subscription.
  void start() {
    if (_disposed) return;
    _timer?.cancel();
    _hadSession = _hasSession();
    _sessionSubscription ??= _sessionChanges?.listen((_) => _onSession());
    unawaited(beat());
    _timer = Timer.periodic(_interval, (_) => unawaited(beat()));
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    unawaited(_sessionSubscription?.cancel());
  }

  void _onSession() {
    final hasSession = _hasSession();
    final signedIn = hasSession && !_hadSession;
    _hadSession = hasSession;
    if (signedIn) unawaited(beat());
  }

  /// The heartbeat body, per the backend contract. Exactly these keys: the
  /// backend rejects unknown fields (`forbidNonWhitelisted`).
  Map<String, dynamic> buildBody() => {
    'terminalId': _terminalId(),
    'appVersion': _truncate(_appVersion, maxAppVersionLength),
    'hostname': _truncate(_hostname(), maxHostnameLength),
    'osVersion': _truncate(_osVersion(), maxOsVersionLength),
    'lastUpdateFailure': _lastUpdateFailure()?.toJson(),
  };

  /// Sends one heartbeat. Never throws.
  Future<void> beat() async {
    if (_disposed) return;
    try {
      if (!_hasSession()) return;
      _hadSession = true;
      await _api.post<void>(path, data: buildBody());
    } catch (_) {
      // Diagnostics only — an unreachable or older backend (404) is fine.
    }
  }

  static String _truncate(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);
}
