import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
  with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLogin() => _authMode == AuthMode.Login;
  bool _isSignup() => _authMode == AuthMode.Signup;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Signup;
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);
    try {
      if (_isLogin()) {
        // Lógica para login
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Lógica para cadastro
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              height: _isLogin() ? 310 : 400,
              // height: _heightAnimation?.value.height ?? (_isLogin() ? 310 : 400),
              width: deviceSize.width * 0.75,
              padding: const EdgeInsets.all(16),
              child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (_email) {
                  final email = _email ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: _passwordController,
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.isEmpty || password.length < 4) {
                    return 'Informe uma senha válida';
                  }
                  return null;
                },
              ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _isSignup() ? 60 : 0,
                    maxHeight: _isSignup() ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.linear,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        decoration:
                        const InputDecoration(labelText: 'Confirmar Senha'),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: _isLogin()
                            ? null
                            : (_password) {
                          final password = _password ?? '';
                          if (password != _passwordController.text) {
                            return 'Senhas diferentes';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    _authMode == AuthMode.Login ? 'Entrar' : 'Cadastrar',
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                ),
              Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(_isLogin()
                    ? 'Criar uma nova conta?'
                    : 'Já possui uma conta?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
