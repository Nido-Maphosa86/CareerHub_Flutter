// lib/screens/apply_screen.dart
//
// A seven-field job application form built with flutter_form_builder.
// ApplyScreen is a HookConsumerWidget — no State subclass, no dispose().
//
// useMemoized wraps the GlobalKey so the same key instance is returned on every
// rebuild. If the key were declared as a plain local variable inside build(),
// a new key object would be created on every rebuild, FormBuilder would see a
// different key, unmount the old FormBuilder and mount a new one — clearing
// every field the user had filled in. useMemoized creates the key once and
// memoises the result for the lifetime of the element.
//
// ref.read is used for the auth state because the authenticated user's email
// does not change while this screen is open. ref.watch would cause the form
// to rebuild on any auth state change, which would reset the email field.

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/auth_state.dart';
import '../providers/auth_notifier.dart';

class ApplyScreen extends HookConsumerWidget {
  final String jobId;

  const ApplyScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // useMemoized creates the key exactly once and returns the same instance on
    // every rebuild. A GlobalKey is a stateful object — recreating it would
    // unmount the FormBuilder and lose all field values.
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    // ref.read — the user's email does not change during this screen's
    // lifetime, so a subscription is unnecessary and wasteful.
    final authAsync = ref.read(authProvider);
    final authState = authAsync.hasValue ? authAsync.value : null;
    final userEmail = authState is Authenticated ? authState.user.email : '';

    void submit() {
      // saveAndValidate() calls save() first, which writes each field's current
      // value into FormBuilderState.value. The validator for the start date
      // reads the saved DateTime — if validate() ran before save(), the field
      // value would be null and the date comparison would behave incorrectly.
      if (formKey.currentState!.saveAndValidate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted!')),
        );
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for this job'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----------------------------------------------------------------
              // Field 1 — Full name
              // required() is first in compose() so an empty field fails fast
              // with "Required" before minLength ever runs. If minLength ran
              // first on an empty string it would always fail with a misleading
              // "too short" message rather than "required".
              // ----------------------------------------------------------------
              FormBuilderTextField(
                name: 'full_name',
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Field 2 — Email, pre-populated from the authenticated user.
              // initialValue wires the stored email into the field on first
              // build. The user can edit it if their application uses a
              // different address.
              // ----------------------------------------------------------------
              FormBuilderTextField(
                name: 'email',
                initialValue: userEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Field 3 — Cover letter. minLines/maxLines together produce a
              // text area that grows but stays readable. minLength(50) ensures
              // the user writes at least a meaningful sentence.
              // ----------------------------------------------------------------
              FormBuilderTextField(
                name: 'cover_letter',
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Cover letter',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(50),
                ]),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Field 4 — Years of experience. Custom validator uses
              // int.tryParse to handle the null/empty/non-numeric cases before
              // checking the value is non-negative.
              // ----------------------------------------------------------------
              FormBuilderTextField(
                name: 'years_experience',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  (value) {
                    final n = int.tryParse(value ?? '');
                    if (n == null) return 'Please enter a whole number';
                    if (n < 0) return 'Cannot be negative';
                    return null;
                  },
                ]),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Field 5 — Earliest start date. saveAndValidate() calls save()
              // before validate(), so by the time the custom validator runs,
              // the selected DateTime is already written into FormBuilderState.
              // Both dates are truncated to midnight before comparison so that
              // selecting today passes — without truncation, "today" would be
              // milliseconds in the past relative to DateTime.now().
              // ----------------------------------------------------------------
              FormBuilderDateTimePicker(
                name: 'start_date',
                inputType: InputType.date,
                decoration: const InputDecoration(
                  labelText: 'Earliest start date',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  (value) {
                    if (value == null) return null;
                    final selected = value.copyWith(
                      hour: 0, minute: 0, second: 0, millisecond: 0,
                    );
                    final today = DateTime.now().copyWith(
                      hour: 0, minute: 0, second: 0, millisecond: 0,
                    );
                    if (selected.isBefore(today)) {
                      return 'Start date must be today or in the future';
                    }
                    return null;
                  },
                ]),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Field 6 — Portfolio URL. Optional field: the validator returns
              // null (pass) when the field is empty or null, and only applies
              // URL format validation when the user has actually entered
              // something. Applying FormBuilderValidators.url() directly
              // without this guard would cause an empty field to fail with
              // "Invalid URL" even though the field is optional.
              // ----------------------------------------------------------------
              FormBuilderTextField(
                name: 'portfolio_url',
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Portfolio URL (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return FormBuilderValidators.url()(value);
                },
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Field 7 — Terms confirmation checkbox. The validator rejects
              // null (untouched) and false (explicitly unchecked). Both must
              // return an error string so the form cannot be submitted without
              // the user actively ticking the box.
              // ----------------------------------------------------------------
              FormBuilderCheckbox(
                name: 'terms',
                title: const Text(
                  'I confirm my application is accurate and complete.',
                ),
                validator: (value) {
                  if (value == null || !value) {
                    return 'You must confirm before submitting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button. saveAndValidate() is synchronous — it runs all
              // validators in order, highlights invalid fields, and returns
              // false if any validator returned a non-null string.
              FilledButton(
                onPressed: submit,
                child: const Text('Submit application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}