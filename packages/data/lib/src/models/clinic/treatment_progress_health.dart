part of 'treatment.dart';

/// How a treatment plan is going — drives the colour of its progress bar.
enum ProgressHealth {
  notStarted('Not started'),
  onTrack('On track'),
  slipping('Missing sessions'),
  atRisk('At risk'),
  done('Completed'),
  stopped('Stopped');

  const ProgressHealth(this.label);

  final String label;
}
