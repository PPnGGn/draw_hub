import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Вход'),
          TextField(),
          TextField(),

          FilledButton(onPressed: () {}, child: Text('Войти')),
          FilledButton(onPressed: () => context.push('/registration'), child: Text('Регистрация')),
        ],
      ),
    );
  }
}
