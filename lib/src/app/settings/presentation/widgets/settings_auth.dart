import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skribla/src/app/auth/data/models/user_model.dart';
import 'package:skribla/src/app/auth/data/repository/auth_repository.dart';
import 'package:skribla/src/core/di/di.dart';
import 'package:skribla/src/core/resource/app_icons.dart';
import 'package:skribla/src/core/util/config.dart';
import 'package:skribla/src/core/util/extension.dart';
import 'package:skribla/src/core/widgets/app_button.dart';

class SettingsAuth extends ConsumerWidget {
  const SettingsAuth({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((it) => it.user));

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null || user?.status == AuthStatus.anonymous) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sign in to save progress',
                textAlign: TextAlign.center,
              ),
              Config.vBox12,
              if (!kIsWeb && Platform.isIOS) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        icon: Icon(AppIcons.appleLogo),
                        text: 'Apple',
                        onPressed: () =>
                            ref.read(authProvider.notifier).signInWithProvider(AuthOptions.apple),
                      ),
                    ),
                    Config.hBox12,
                    Expanded(
                      child: AppButton(
                        icon: Icon(AppIcons.googleLogo),
                        text: 'Google',
                        onPressed: () =>
                            ref.read(authProvider.notifier).signInWithProvider(AuthOptions.google),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                AppButton(
                  icon: Icon(AppIcons.googleLogo),
                  text: 'Continue with Google',
                  onPressed: () =>
                      ref.read(authProvider.notifier).signInWithProvider(AuthOptions.google),
                ),
              ],
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                icon: Icon(AppIcons.trashSimple),
                text: 'Delete account',
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: Config.radius8,
                  ),
                ),
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog.adaptive(
                        title: const Text(
                          'Are you sure?',
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          'Deleting your account cannot be reversed.',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          AppButton(
                            type: ButtonType.text,
                            text: 'Cancel',
                            onPressed: () => context.pop(false),
                          ),
                          AppButton(
                            type: ButtonType.text,
                            text: 'Delete',
                            onPressed: () => context.pop(true),
                          ),
                        ],
                      );
                    },
                  ).then((proceed) {
                    if (proceed != true) return;
                    ref.read(authProvider.notifier).deleteAccount();
                  });
                },
              ),
            ],
          );
        }
      },
    );
  }
}
