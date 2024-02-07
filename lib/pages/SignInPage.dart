import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stads/providers/AuthProvider.dart';
import 'package:stads/providers/StadsGradeProvider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for form validation

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null; // Return null for no validation error
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null; // Return null for no validation error
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Validate the form
                  if (_formKey.currentState?.validate() == true) {
                    // Validation passed, proceed with login
                    await authProvider.login(
                      _usernameController.text,
                      _passwordController.text,
                    );

                    // Check for an error message and display it
                    if (authProvider.notificationMessage != 'Login Success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.notificationMessage!),
                        ),
                      );
                    } else {
                      await Provider.of<StadsGradesProvider>(context,
                              listen: false)
                          .fetchGrades();
                    }
                  }
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
