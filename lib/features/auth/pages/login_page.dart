import 'package:draw_hub/features/auth/widgets/custom_text_field.dart';
import 'package:draw_hub/features/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                'Вход',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: 'E-mail',
                hintText: 'Введите email',
                controller: TextEditingController(),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: 'Пароль',
                hintText: 'Введите пароль',
                controller: TextEditingController(),
              ),
              const Spacer(),
              GradientButton(onPressed: () {}, text: 'Войти'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.push('/registration'),
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
