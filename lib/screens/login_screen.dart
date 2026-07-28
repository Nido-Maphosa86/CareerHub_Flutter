// lib/screens/login_screen.dart
//
// The login screen. It is a ConsumerStatefulWidget because it owns two
// TextEditingControllers that must be disposed when the screen is removed
// from the tree. Disposing them prevents memory leaks.
//
// The screen never calls a navigation method. GoRouter's redirect callback
// watches authStateListenableProvider and fires automatically when
// AuthNotifier emits Authenticated — the router drives the transition,
// not this screen. This keeps the screen's responsibility narrow: collect
// credentials and call login(). The router decides where to go next.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Each controller tracks the text in its field and must be disposed to free
  // the underlying platform resources when the widget leaves the tree.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch authProvider so the widget rebuilds whenever auth state
    // changes — this is what makes the spinner appear and disappear and the
    // error message show without any additional setState calls.
    final authAsync = ref.watch(authProvider);
    final authState = authAsync.hasValue ? authAsync.value : null;

    // True only while the login network call is in progress. The Authenticating
    // subtype is set synchronously at the start of login() before any await,
    // so the spinner appears in the same frame as the tap.
    final isLoading = authState is Authenticating;

    // Non-null only when login failed. Uses Dart 3 pattern matching to
    // destructure the message field directly from the AuthError subtype without
    // a cast or a null check on a separate variable.
    final errorMessage = switch (authState) {
      AuthError(:final message) => message,
      _ => null,
    };

    return Scaffold(
      // No AppBar — the login screen is a full-screen gate. Showing a title bar
      // here would suggest the user is inside the authenticated app shell.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App identity
                Text(
                  'CareerHub',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to find your next opportunity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email field. textInputAction.next moves focus to the password
                // field without closing the keyboard.
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field. textInputAction.done closes the keyboard and
                // calls _submit, so the user can sign in without tapping the
                // button.
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Error message — only rendered when errorMessage is non-null.
                // Placed between the password field and the button so it is
                // clearly associated with the failed login attempt.
                if (errorMessage != null) ...[
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Sign in button. Disabled (onPressed is null) while loading so
                // the user cannot trigger a second login call before the first
                // one resolves. Shows a small spinner inside the button instead
                // of the label text when loading is true.
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Sign in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reads the notifier (not watches — this is a callback, not a build) and
  // calls login with the trimmed email and the raw password. Trimming the email
  // prevents invisible whitespace from causing "invalid credentials" errors.
  void _submit() {
    ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }
}