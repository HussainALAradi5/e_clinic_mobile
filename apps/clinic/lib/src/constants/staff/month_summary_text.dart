/// Text of the owner's month summary on the phone.
abstract final class MonthSummaryText {
  static const title = 'Month summary';
  static const link = 'The month at a glance';
  static const vsBefore = 'vs month before';
  static const newFigure = 'new';

  /// The figures shown, in order: (key, label, lower is better).
  static const figures = <(String, String, bool)>[
    ('revenue', 'Revenue', false),
    ('net_result', 'Result', false),
    ('collected', 'Collected', false),
    ('expenses', 'Expenses', true),
    ('owed_by_patients', 'Owed by patients', true),
    ('owed_by_insurers', 'Owed by insurers', true),
    ('visits_completed', 'Visits', false),
    ('no_shows', 'No-shows', true),
    ('new_patients', 'New patients', false),
    ('packages_sold', 'Packages sold', false),
  ];
}
