import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/presentation/providers/auth_provider.dart';
import 'package:client/features/auth/presentation/pages/sign_in_page.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool showLoading;

  const AuthGuard({
    Key? key,
    required this.child,
    this.showLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(isAuthenticatedProvider);

    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return child;
        } else {
          // Token is invalid, redirect to sign in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
            );
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      loading: () {
        if (showLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Validating authentication...'),
                ],
              ),
            ),
          );
        } else {
          return child;
        }
      },
      error: (error, stackTrace) {
        // On error, redirect to sign in
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false,
          );
        });
        return const Scaffold(
          body: Center(
            child: Text('Authentication error. Please sign in again.'),
          ),
        );
      },
    );
  }
}
