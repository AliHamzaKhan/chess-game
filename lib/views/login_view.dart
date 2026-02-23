import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class LoginView extends StatelessWidget {
  final AuthService auth = Get.find<AuthService>();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_esports, size: 100, color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              Text(
                'Chess Master',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => auth.signInWithGoogle(),
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => auth.signInAsGuest(),
                icon: const Icon(Icons.person_outline),
                label: const Text('Continue as Guest'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              if(kDebugMode)...[
                // Mock Login for simulator without Google Services
                // TextButton(
                //     onPressed: () => _mockLogin(),
                //     child: const Text("Dev: Quick Login (Mock)")
                // )
              ]

            ],
          ),
        ),
      ),
    );
  }
  
  void _mockLogin() {
      // Direct call to fake auth flow for testing
      // This is a workaround since we can't real-google-login in this environment usually
      Get.snackbar("Dev Mode", "Google Login requires configuration. Use Google Button in real app.");
  }
}
