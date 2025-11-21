import 'package:draw_hub/auth/usecases/auth_usecase.dart';
import 'package:draw_hub/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final AuthUseCase _authUseCase = AuthUseCase(AuthService());
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Регистрация'),
          TextField(controller: _emailController),
          TextField(controller: _passwordController),
          TextField(),
          TextField(),

          FilledButton(
            onPressed: () async {
              final email = _emailController.text.trim();
              final password = _passwordController.text.trim();

              try {
                final user = await _authUseCase.registrationUseCase(
                  email: email,
                  password: password,
                );

                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Регистрация успешна!')),
                  );
                  // Можно сделать переход на другой экран
                  // Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Ошибка регистрации')));
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
              }
            },
            child: Text('Регистрация'),
          ),
        ],
      ),
    );
  }
}
