import 'package:draw_hub/features/auth/domain/auth_controller.dart';
import 'package:draw_hub/features/auth/widgets/custom_text_field.dart';
import 'package:draw_hub/features/auth/widgets/error_snack_bar.dart';
import 'package:draw_hub/features/widgets/gradient_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operationState = ref.watch(authControllerProvider);

    // КЛЮЧЕВОЙ МОМЕНТ: реактивно слушаем изменения состояния
    // Это сработает автоматически при любом изменении authControllerProvider
    ref.listen<AuthOperationState>(authControllerProvider, (previous, next) {
      // Показываем ошибки автоматически
      if (next is AuthOperationError) {
        showErrorSnackBar(context, next.message);
      }

      // Опционально: можно показать success toast
      // if (next is AuthOperationSuccess) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Вход выполнен успешно')),
      //   );
      // }
    });

    final isLoading = operationState is AuthOperationLoading;

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
                  'Вход',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'E-mail',
                  hintText: 'Введите email',
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Пароль',
                  hintText: 'Введите пароль',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const Spacer(),
                GradientButton(
                  onPressed: isLoading ? () {} : () => _handleLogin(),

                  text: isLoading ? 'Загрузка...' : 'Войти',
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () => context.push('/registration'),
                  child: const Text('Регистрация'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Валидация на UI уровне
    if (!EmailValidator.validate(email)) {
      showErrorSnackBar(context, 'Неверный формат e-mail');
      return;
    }

    if (password.isEmpty) {
      showErrorSnackBar(context, 'Введите пароль');
      return;
    }

    // Просто вызываем метод
    // ref.listen автоматически покажет ошибку если что-то пойдет не так
    await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password);

    // После успешного логина:
    // 1. authUserProvider (StreamProvider) получит обновление от Firebase
    // 2. router.dart слушает authUserProvider через ref.listen
    // 3. router.refresh() вызовет redirect
    // 4. redirect увидит что user != null и перенаправит на /gallery

    // Ничего вручную делать НЕ нужно!
  }
}
