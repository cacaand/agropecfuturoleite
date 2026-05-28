import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

// ─── SECURITY CONFIG ──────────────────────────────────────────────────────────

class AppSecurity {
  static const _pinKey        = '_gl_pin_h';
  static const _lockKey       = '_gl_lock';
  static const _attKey        = '_gl_att';
  static const _lockoutKey    = '_gl_lkout';
  static const _sessionKey    = '_gl_sess';
  static const _maxAttempts   = 5;
  static const _lockMinutes   = 10;
  static const _sessionHours  = 8;
  static const _salt          = r'gL!2025@IAmina#Salt$Sec';

  // ── Hashing ────────────────────────────────────────────────────────────────

  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin + _salt);
    return sha256.convert(sha256.convert(bytes).bytes).toString(); // double-hash
  }

  // ── PIN management ─────────────────────────────────────────────────────────

  static Future<bool> isPinSet() async {
    final p = await SharedPreferences.getInstance();
    return p.containsKey(_pinKey);
  }

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_pinKey, _hashPin(pin));
    await p.setBool(_lockKey, true);
    await p.setInt(_attKey, 0);
    await _refreshSession(p);
  }

  static Future<PinResult> verifyPin(String pin) async {
    final p = await SharedPreferences.getInstance();

    // Lockout check
    final lockoutUntil = p.getInt(_lockoutKey) ?? 0;
    final remaining    = lockoutUntil - DateTime.now().millisecondsSinceEpoch;
    if (remaining > 0) {
      return PinResult.locked(Duration(milliseconds: remaining));
    }

    final stored  = p.getString(_pinKey) ?? '';
    final correct = stored == _hashPin(pin);

    if (correct) {
      await p.setInt(_attKey, 0);
      await p.setInt(_lockoutKey, 0);
      await _refreshSession(p);
      return PinResult.ok();
    }

    final attempts = (p.getInt(_attKey) ?? 0) + 1;
    await p.setInt(_attKey, attempts);

    if (attempts >= _maxAttempts) {
      final until = DateTime.now().add(Duration(minutes: _lockMinutes)).millisecondsSinceEpoch;
      await p.setInt(_lockoutKey, until);
      await p.setInt(_attKey, 0);
      return PinResult.locked(Duration(minutes: _lockMinutes));
    }
    return PinResult.wrong(_maxAttempts - attempts);
  }

  static Future<void> removePin() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_pinKey);
    await p.setBool(_lockKey, false);
  }

  // ── Session ────────────────────────────────────────────────────────────────

  static Future<void> _refreshSession(SharedPreferences p) async {
    final exp = DateTime.now().add(Duration(hours: _sessionHours)).millisecondsSinceEpoch;
    await p.setInt(_sessionKey, exp);
  }

  static Future<bool> isSessionValid() async {
    final p = await SharedPreferences.getInstance();
    final exp = p.getInt(_sessionKey) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < exp;
  }

  static Future<bool> isLockEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_lockKey) ?? false;
  }

  static Future<int> remainingAttempts() async {
    final p = await SharedPreferences.getInstance();
    return _maxAttempts - (p.getInt(_attKey) ?? 0);
  }

  // ── Input sanitization ─────────────────────────────────────────────────────

  /// Strips dangerous chars, trims, caps length
  static String sanitize(String input, {int maxLen = 500}) {
    return input
        .replaceAllMapped(RegExp(r'[<>"’\\;{}()\[\]|`]'), (match) => '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim()
        .substring(0, min(input.length, maxLen));
  }

  static String sanitizeNumber(String input) =>
      input.replaceAll(RegExp(r'[^0-9.,\-]'), '').trim();

  // ── Validators ─────────────────────────────────────────────────────────────

  static bool isValidEmail(String email) =>
      RegExp(r'^[\w\.-]{1,64}@[\w\.-]{1,253}\.\w{2,10}$').hasMatch(email.trim());

  static bool isValidCpf(String cpf) {
    final d = cpf.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11 || RegExp(r'^(\d)\1+$').hasMatch(d)) return false;
    int sum = 0;
    for (int i = 0; i < 9; i++) sum += int.parse(d[i]) * (10 - i);
    int r = 11 - (sum % 11); if (r >= 10) r = 0;
    if (r != int.parse(d[9])) return false;
    sum = 0;
    for (int i = 0; i < 10; i++) sum += int.parse(d[i]) * (11 - i);
    r = 11 - (sum % 11); if (r >= 10) r = 0;
    return r == int.parse(d[10]);
  }

  static bool isValidCardNumber(String number) {
    final d = number.replaceAll(RegExp(r'\D'), '');
    if (d.length < 13 || d.length > 19) return false;
    int sum = 0; bool alt = false;
    for (int i = d.length - 1; i >= 0; i--) {
      int n = int.parse(d[i]);
      if (alt) { n *= 2; if (n > 9) n -= 9; }
      sum += n; alt = !alt;
    }
    return sum % 10 == 0;
  }

  static String? validateRequired(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? '$field é obrigatório' : null;

  static String? validateMinLen(String? v, int min, String field) =>
      (v == null || v.trim().length < min) ? '$field deve ter pelo menos $min caracteres' : null;

  // ── Secure token generator ─────────────────────────────────────────────────

  static String generateToken(int length) {
    final rng    = Random.secure();
    final values = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64Url.encode(values).substring(0, length);
  }

  // ── Audit log ──────────────────────────────────────────────────────────────

  static Future<void> logEvent(String event, {String? detail}) async {
    final p = await SharedPreferences.getInstance();
    final logs = jsonDecode(p.getString('_audit_log') ?? '[]') as List;
    logs.add({
      'ts':     DateTime.now().toIso8601String(),
      'event':  event,
      'detail': detail,
    });
    // Keep last 200 events
    if (logs.length > 200) logs.removeRange(0, logs.length - 200);
    await p.setString('_audit_log', jsonEncode(logs));
  }

  static Future<List<Map<String,dynamic>>> getAuditLog() async {
    final p = await SharedPreferences.getInstance();
    final raw = jsonDecode(p.getString('_audit_log') ?? '[]') as List;
    return raw.reversed.map((e) => Map<String,dynamic>.from(e)).toList();
  }
}

class PinResult {
  final bool success;
  final int? remainingAttempts;
  final Duration? lockDuration;
  PinResult._({required this.success, this.remainingAttempts, this.lockDuration});
  factory PinResult.ok()                      => PinResult._(success: true);
  factory PinResult.wrong(int remaining)      => PinResult._(success: false, remainingAttempts: remaining);
  factory PinResult.locked(Duration duration) => PinResult._(success: false, lockDuration: duration);
  bool get isLocked => lockDuration != null;
}

// ─── SECURITY WRAPPER (auto-lock) ─────────────────────────────────────────────

class SecurityWrapper extends StatefulWidget {
  final Widget child;
  const SecurityWrapper({super.key, required this.child});
  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper> with WidgetsBindingObserver {
  bool _locked = false;
  DateTime? _bgTime;
  static const _autoLockMinutes = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  Future<void> _checkLock() async {
    final pinSet = await AppSecurity.isPinSet();
    final sessOk = await AppSecurity.isSessionValid();
    if (pinSet && (!sessOk) && mounted) {
      setState(() => _locked = true);
      AppSecurity.logEvent('AUTO_LOCK', detail: 'Session expired');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _bgTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _bgTime != null) {
      final elapsed = DateTime.now().difference(_bgTime!);
      if (elapsed.inMinutes >= _autoLockMinutes) {
        AppSecurity.isPinSet().then((set) {
          if (set && mounted) {
            setState(() => _locked = true);
            AppSecurity.logEvent('AUTO_LOCK', detail: '${elapsed.inMinutes}min background');
          }
        });
      }
    }
  }

  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_locked) return PinLockScreen(onUnlocked: () {
      setState(() => _locked = false);
      AppSecurity.logEvent('UNLOCK_SUCCESS');
    });
    return widget.child;
  }
}

// ─── PIN LOCK SCREEN ──────────────────────────────────────────────────────────

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const PinLockScreen({super.key, required this.onUnlocked});
  @override
  State<PinLockScreen> createState() => _PinLockState();
}

class _PinLockState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _pin   = '';
  String _error = '';
  bool   _busy  = false;
  late AnimationController _shake;
  late Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake    = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shake, curve: Curves.elasticIn));
  }

  @override
  void dispose() { _shake.dispose(); super.dispose(); }

  void _tap(String k) {
    if (_busy || _pin.length >= 6) return;
    setState(() { _pin += k; _error = ''; });
    if (_pin.length == 6) _verify();
  }

  void _del() { if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1)); }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final result = await AppSecurity.verifyPin(_pin);
    if (result.success) {
      widget.onUnlocked();
      return;
    }
    _shake.forward(from: 0);
    setState(() {
      _pin = '';
      _busy = false;
      if (result.isLocked) {
        final mins = (result.lockDuration!.inSeconds / 60).ceil();
        _error = '🔒 Bloqueado por $mins minuto${mins > 1 ? "s" : ""}. Tente mais tarde.';
      } else {
        _error = 'PIN incorreto — ${result.remainingAttempts} tentativa${result.remainingAttempts != 1 ? "s" : ""} restante${result.remainingAttempts != 1 ? "s" : ""}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebar,
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Logo
          Container(width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.green700, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.grass_rounded, color: Colors.white, size: 40)),
          const SizedBox(height: 16),
          const Text('GadoLeite ERP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Digite seu PIN de 6 dígitos', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 36),

          // PIN dots with shake animation
          AnimatedBuilder(animation: _shakeAnim, builder: (_, __) => Transform.translate(
            offset: Offset(sin(_shakeAnim.value * pi * 6) * 8, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: i < _pin.length ? 18 : 14,
                height: i < _pin.length ? 18 : 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                    ? (_error.isNotEmpty ? AppColors.red600 : AppColors.green400)
                    : Colors.white.withOpacity(0.2)),
              ))),
          )),
          const SizedBox(height: 14),

          if (_error.isNotEmpty) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(_error, textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFF8080), fontSize: 12, height: 1.4))),

          const SizedBox(height: 28),

          // Numpad
          if (_busy)
            const CircularProgressIndicator(color: AppColors.green400, strokeWidth: 2)
          else _buildPad(),
        ]),
      ))),
    );
  }

  Widget _buildPad() {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GridView.count(
        shrinkWrap: true, crossAxisCount: 3,
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7,
        children: keys.map((k) => k.isEmpty ? const SizedBox() : GestureDetector(
          onTap: () => k == '⌫' ? _del() : _tap(k),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(k == '⌫' ? 0.05 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Center(child: Text(k,
              style: TextStyle(color: Colors.white, fontSize: k == '⌫' ? 20 : 24,
                fontWeight: FontWeight.w300))),
          ),
        )).toList(),
      ),
    );
  }
}

// ─── PIN SETUP SCREEN ─────────────────────────────────────────────────────────

class PinSetupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const PinSetupScreen({super.key, required this.onDone});
  @override
  State<PinSetupScreen> createState() => _PinSetupState();
}

class _PinSetupState extends State<PinSetupScreen> {
  String _pin1 = '', _pin2 = '';
  int    _step = 1; // 1=enter, 2=confirm
  String _err  = '';

  void _tap(String k) {
    setState(() {
      _err = '';
      if (_step == 1) {
        if (_pin1.length < 6) { _pin1 += k; if (_pin1.length == 6) { _step = 2; } }
      } else {
        if (_pin2.length < 6) { _pin2 += k; if (_pin2.length == 6) _confirm(); }
      }
    });
  }

  void _del() => setState(() {
    if (_step == 2 && _pin2.isNotEmpty) _pin2 = _pin2.substring(0, _pin2.length-1);
    else if (_step == 1 && _pin1.isNotEmpty) _pin1 = _pin1.substring(0, _pin1.length-1);
  });

  Future<void> _confirm() async {
    if (_pin1 != _pin2) {
      setState(() { _pin2 = ''; _err = 'PINs não coincidem. Tente novamente.'; _step = 2; });
      return;
    }
    await AppSecurity.setPin(_pin1);
    AppSecurity.logEvent('PIN_SET');
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final current = _step == 1 ? _pin1 : _pin2;
    return Scaffold(
      backgroundColor: AppColors.sidebar,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_step == 1 ? Icons.lock_outline_rounded : Icons.lock_rounded,
            color: AppColors.green400, size: 48),
          const SizedBox(height: 16),
          Text(_step == 1 ? 'Crie seu PIN de segurança' : 'Confirme seu PIN',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(_step == 1 ? 'Escolha 6 dígitos para proteger o app' : 'Digite novamente para confirmar',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 36),

          // Dots
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: i < current.length ? 18 : 14, height: i < current.length ? 18 : 14,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: i < current.length ? AppColors.green400 : Colors.white.withOpacity(0.2)),
            ))),
          if (_err.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_err, style: const TextStyle(color: Color(0xFFFF8080), fontSize: 12)),
          ],
          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: GridView.count(
              shrinkWrap: true, crossAxisCount: 3,
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7,
              children: ['1','2','3','4','5','6','7','8','9','','0','⌫'].map((k) =>
                k.isEmpty ? const SizedBox() : GestureDetector(
                  onTap: () => k == '⌫' ? _del() : _tap(k),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Center(child: Text(k,
                      style: TextStyle(color: Colors.white, fontSize: k=='⌫' ? 20 : 24, fontWeight: FontWeight.w300))),
                  ),
                ),
              ).toList(),
            ),
          ),
        ]),
      ))),
    );
  }
}
