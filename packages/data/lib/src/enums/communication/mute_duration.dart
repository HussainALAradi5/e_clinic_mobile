/// Mirror of App\Enums\Communication\MuteDuration — how long I mute a chat.
enum MuteDuration {
  eightHours('8h'),
  oneWeek('1w'),
  always('always');

  const MuteDuration(this.wire);

  /// The value the API takes.
  final String wire;
}
