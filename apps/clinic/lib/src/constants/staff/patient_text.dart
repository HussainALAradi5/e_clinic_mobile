/// Wording of the patient files list and the patient cards.
abstract final class PatientText {
  static const patientFiles = 'Patient files';
  static const emergencyAccess = 'Emergency access';
  static const noPatientFound = 'No patient with that file number or ID.';
  static const reasonTooShort = 'Give the reason (10 letters or more).';
  static const lookupLabel = 'File number or national ID';
  static const lookupHint = 'PRS-000123';
  static const find = 'Find';
  static const reasonHint = 'e.g. Collapsed in the waiting room; need allergies';
  static const allergies = 'Allergies';
  static const medicalHistory = 'Medical history';
  static const allergiesHint = 'e.g. Penicillin';
  static const familyHistoryHint = 'e.g. Father: type 2 diabetes';
  static const bloodGroup = 'Blood group';
  static const chronicConditions = 'Chronic conditions';
  static const familyHistory = 'Family history';
  static const surgicalHistory = 'Surgical history';
  static const insurance = 'Insurance';
  static const policy = 'Policy';
  static const insuranceExpires = 'Insurance expires';
  static const frontDeskNotes = 'Front-desk notes';

  static String showAll(int count) => 'Show all $count';

  static const noPatientFilesYet = 'No patient files yet';
  static const noMatch = 'No match';
  static const noMatchHint = 'Try part of the name, the file number or the mobile.';
  static const alreadyInCare = 'Already in your care — no emergency access needed.';
  static const openTheFile = 'Open the file';
  static const openInEmergency = 'Open in an emergency';
  static const selfPaying = 'Self-paying';
  static const emptyFile = 'Nothing in this file yet.';
  static const emergencyNote =
      'For a patient who is not under your care. Every use is recorded in the audit trail and the '
      'administrators are told. Access ends after 12 hours.';
}
