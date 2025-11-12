import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Регистрация'),
          TextField(),
          TextField(),
          TextField(),
          TextField(),

          FilledButton(onPressed: () {}, child: Text('Регистрация')),
        ],
      ),
    );
  }
}
