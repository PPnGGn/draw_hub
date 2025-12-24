import 'package:draw_hub/features/auth/widgets/custom_text_field.dart';
import 'package:draw_hub/features/auth/domain/auth_notifier.dart';
import 'package:draw_hub/features/auth/domain/auth_state.dart';
import 'package:draw_hub/features/auth/widgets/error_snack_bar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthStateLoading;

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
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordConfirmController,
                  hintText: 'Введите пароль повторно',
                  labelText: 'Подтвердите пароль',
                  isPassword: true,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: isLoading ? null : _handleRegistration,
                  child: isLoading
                      ? const Text('Загрузка...')
                      : const Text('Регистрация'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _passwordConfirmController.text.trim();

    // Валидация email
    if (!EmailValidator.validate(email)) {
      showErrorSnackBar(context, 'Неверный e-mail');
      return;
    }

    // Валидация пароля (минимальная длина)
    if (password.length < 6) {
      showErrorSnackBar(context, 'Слишком легкий пароль');
      return;
    }

    // Совпадение паролей
    if (password != confirm) {
      showErrorSnackBar(context, 'Пароли не совпадают');
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .register(email: email, password: password);

    final newState = ref.read(authNotifierProvider);
    if (newState is AuthStateAuthenticated) {
    } else if (newState is AuthStateError) {
      if (!mounted) return;
      showErrorSnackBar(context, newState.message);
    }
  }
}
