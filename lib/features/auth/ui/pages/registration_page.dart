import 'package:draw_hub/features/auth/domain/auth_controller.dart';
import 'package:draw_hub/features/auth/ui/widgets/custom_text_field.dart';
import 'package:draw_hub/features/auth/ui/widgets/error_snack_bar.dart';
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
  
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordConfirmFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthOperationLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/png/background_img.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                Text(
                  'Регистрация',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  hintText: 'Введите имя',
                  labelText: 'Имя',
                  onSubmitted: () => _emailFocusNode.requestFocus(),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  hintText: 'Введите email',
                  labelText: 'E-mail',
                  onSubmitted: () => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hintText: 'Введите пароль',
                  labelText: 'Пароль',
                  isPassword: true,
                  onSubmitted: () => _passwordConfirmFocusNode.requestFocus(),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordConfirmController,
                  focusNode: _passwordConfirmFocusNode,
                  hintText: 'Введите пароль повторно',
                  labelText: 'Подтвердите пароль',
                  isPassword: true,
                  onSubmitted: _handleRegistration,
                ),
                const SizedBox(height: 100),
          
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _passwordConfirmController.text.trim();

    if (name.isEmpty) {
      showErrorSnackBar(context, 'Введите имя');
      return;
    }

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

    // Сохраняем notifier перед асинхронной операцией
    final authNotifier = ref.read(authControllerProvider.notifier);
    
    await authNotifier.register(email: email, password: password, displayName: name);

    // Проверяем, что виджет все еще смонтирован перед использованием ref
    if (!mounted) return;
    
    final newState = ref.read(authControllerProvider);
    if (newState is AuthOperationSuccess) {
    } else if (newState is AuthOperationError) {
      showErrorSnackBar(context, newState.message);
    }
  }
}
