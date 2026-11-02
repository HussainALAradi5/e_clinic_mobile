part of 'portal_providers.dart';

/// The patient's file; [Profile.replace] after an edit.
class Profile extends AsyncNotifier<Patient> {
  @override
  Future<Patient> build() => ref.watch(portalRepositoryProvider).profile();

  void replace(Patient patient) => state = AsyncData(patient);
}
