import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/auth_models.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/message_banner.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _mobile = TextEditingController();
  final _nationalId = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _mobile.dispose();
    _nationalId.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            RegisterRequest(
              fullName: _fullName.text,
              mobile: _mobile.text,
              nationalId: _nationalId.text,
              email: _email.text,
              password: _password.text,
            ),
          );
      if (!mounted) return;
      context.go(Routes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = _composeError(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = S.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Prefers field-level messages from the backend when present.
  String _composeError(ApiException e) {
    if (e.fieldErrors.isNotEmpty) {
      return e.fieldErrors.values.join('\n');
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text(S.createAccount)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      S.createAccount,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S.registerSubtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: c.mutedForeground),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      MessageBanner(message: _error!),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: S.fullName,
                      controller: _fullName,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: S.mobile,
                      hint: '05XXXXXXXX',
                      controller: _mobile,
                      prefixIcon: Icons.phone_iphone_rounded,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      ],
                      autofillHints: const [AutofillHints.telephoneNumber],
                      validator: Validators.mobile,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: S.nationalId,
                      hint: '1XXXXXXXXX',
                      controller: _nationalId,
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: Validators.nationalId,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: S.email,
                      hint: 'name@example.com',
                      controller: _email,
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: S.password,
                      controller: _password,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: S.register,
                      loading: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.haveAccount,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: c.mutedForeground),
                        ),
                        TextButton(
                          onPressed:
                              _submitting ? null : () => context.pop(),
                          child: const Text(S.login),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
