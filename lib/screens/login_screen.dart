// lib/screens/login_screen.dart
//
// Assignment 3.1 refactor: ConsumerStatefulWidget -> HookConsumerWidget.
// The entire State subclass, createState(), dispose(), and the _submit()
// instance method are gone. The file now contains exactly one class.
//
// useTextEditingController() replaces field declarations on a State class.
// The hook framework stores the controller in a numerically indexed list on
// the element — not in a named field — and calls dispose() automatically
// when the widget unmounts. There is no way to forget disposal.
//
// The submit() local function captures the controllers from the same call
// frame, so it needs no parameters and no access to instance state.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/auth_state.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // useTextEditingController() creates the controller on the first build and
    // returns the same instance on every subsequent build. When the widget
    // unmounts, the hook framework disposes it automatically — no dispose()
    // override needed anywhere in this file.
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final authAsync = ref.watch(authProvider);
    final authState = authAsync.hasValue ? authAsync.value : null;

    // True only while the login network call is in flight. Authenticating is
    // set synchronously at the start of login() before any await, so the
    // spinner appears in the same frame as the tap.
    final isLoading = authState is Authenticating;

    // Non-null only when the last login attempt failed. Pattern-matches on
    // the AuthError subtype to destructure the message field directly.
    final errorMessage = switch (authState) {
      AuthError(:final message) => message,
      _ => null,
    };

    // Local function captures controllers from this call frame — no instance
    // state needed. ref.read is correct because this is a callback, not a
    // reactive subscription.
    void submit() {
      ref.read(authProvider.notifier).login(
            emailController.text.trim(),
            passwordController.text,
          );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                TextField(
                  controller: emailController,
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
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  // Calls the local submit function when the user presses done
                  // on the keyboard — no instance method reference needed.
                  onSubmitted: (_) => submit(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),
                const SizedBox(height: 16),
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
                FilledButton(
                  onPressed: isLoading ? null : submit,
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
}