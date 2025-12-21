import 'package:draw_hub/features/auth/usecases/auth_usecase.dart';
import 'package:draw_hub/features/auth/widgets/custom_text_field.dart';
import 'package:draw_hub/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final AuthUseCase _authUseCase = AuthUseCase(AuthService());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/png/background_img.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  'Регистрация',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Введите имя',
                  labelText: 'Имя',
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Введите email',
                  labelText: 'E-mail',
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Введите пароль',
                  labelText: 'Пароль',
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordConfirmController,
                  hintText: 'Введите пароль повторно',
                  labelText: 'Подтвердите пароль',
                ),
                const Spacer(),
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка регистрации')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                    }
                  },
                  child: Text('Регистрация'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
