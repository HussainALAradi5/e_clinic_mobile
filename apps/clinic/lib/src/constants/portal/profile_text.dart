/// Wording of the patient's profile.
abstract final class ProfileText {
  static const myProfile = 'My profile';
  static const edit = 'Edit';
  static const frontDeskChanges = 'To change your name, ID or insurance, visit the front desk with your documents.';
  static const contactDetails = 'Contact details';
  static const contactsOptional = 'Optional, up to three.';
  static const addContact = 'Add a contact';
  static const removeContact = 'Remove this contact';
  static const insurer = 'Insurer';
  static const policyNumber = 'Policy number';
  static const covers = 'Covers';
  static const validUntil = 'Valid until';

  static String contactNumber(int number) => 'Contact $number';

  static const personal = 'Personal';
  static const contact = 'Contact';
  static const insurance = 'Insurance';
  static const saved = 'Your details are saved.';
  static const mobileInvalid = 'Enter your mobile number with the country code.';
  static const name = 'Name';
  static const relation = 'Relation (e.g. wife, son)';
  static const phoneInvalid = 'Enter the phone number with the country code.';
  static const phone = 'Phone';
}
