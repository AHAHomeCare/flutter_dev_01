import 'package:flutter/material.dart';

import '../services/account_api.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.api, required this.onSignedIn});

  final AccountApi api;
  final ValueChanged<AccountSession> onSignedIn;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _submitting = false;
  bool _hidePassword = true;
  String? _message;
  bool _hasError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_form.currentState!.validate()) return;
    final email = _email.text.trim();
    final password = _password.text;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      if (_register) {
        await widget.api.register(email, password);
        if (!mounted) return;
        _password.clear();
        setState(() {
          _register = false;
          _hidePassword = true;
          _hasError = false;
          _message = 'Đăng ký thành công. Vui lòng đăng nhập.';
        });
      } else {
        final session = await widget.api.login(email, password);
        if (!mounted) return;
        _password.clear();
        widget.onSignedIn(session);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _message = error is AccountApiException
            ? error.message
            : 'Không thể kết nối hoặc đọc phản hồi từ API. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = _register ? 'Đăng ký' : 'Đăng nhập';
    return Scaffold(
      appBar: AppBar(title: Text(action)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _email,
                        enabled: !_submitting,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.length > 254 ||
                              !RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(email)) {
                            return 'Nhập email hợp lệ.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        enabled: !_submitting,
                        obscureText: _hidePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          suffixIcon: IconButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() {
                                    _hidePassword = !_hidePassword;
                                  }),
                            tooltip: _hidePassword
                                ? 'Hiện mật khẩu'
                                : 'Ẩn mật khẩu',
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final length = value?.length ?? 0;
                          return length < 8 || length > 128
                              ? 'Mật khẩu phải có từ 8 đến 128 ký tự.'
                              : null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_message case final String message) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            message,
                            style: TextStyle(
                              color: _hasError
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: Text(_submitting ? 'Đang xử lý…' : action),
                      ),
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => setState(() {
                                _register = !_register;
                                _password.clear();
                                _hidePassword = true;
                                _message = null;
                                _form.currentState!.clearError();
                              }),
                        child: Text(
                          _register
                              ? 'Đã có tài khoản? Đăng nhập'
                              : 'Chưa có tài khoản? Đăng ký',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
