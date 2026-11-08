import 'package:e_clinic_app/src/screens/staff/patient_detail_screen.dart';
import 'package:e_clinic_app/src/utilities/staff/activity_changes.dart';
import 'package:e_clinic_app/src/widgets/staff/activity/activity_log_section.dart';
import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityEntry _entry(int n, {String? by = 'Amal Haddad', String action = 'viewed', String label = 'Opened the page'}) =>
    ActivityEntry(
      id: 'e$n',
      action: action,
      actionLabel: label,
      entity: 'patient_profile',
      changedBy: by,
      createdAt: DateTime.utc(2026, 11, 8, 15, 27),
    );

Paged<ActivityEntry> _page(List<ActivityEntry> items, {String? next}) => Paged(
  items: items,
  meta: PageMeta(perPage: 20, nextCursor: next),
);

/// Answers with [pages] by cursor (null is the first page), or fails when [failure] is set.
class _FakeActivity implements ActivityRepository {
  _FakeActivity(this.pages);

  final Map<String?, Paged<ActivityEntry>> pages;
  final cursors = <String?>[];
  Object? failure;

  @override
  Future<Paged<ActivityEntry>> list(ActivityEntity entity, String id, {required int perPage, String? cursor}) async {
    cursors.add(cursor);
    if (failure != null) throw failure!;
    return pages[cursor]!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePatients implements PatientRepository {
  @override
  Future<Patient> get(String id) async => Patient.fromJson({
    'id': id,
    'code': 'PRS-1',
    'full_name': 'Sara Ali',
    'gender': 'female',
    'date_of_birth': '1990-01-01',
    'phone': '33334444',
    'person': {'id': 'x', 'version': 1},
    'version': 1,
  });

  @override
  Future<List<PatientTimelineEntry>> timeline(String id) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _FakeActivity repo, {double width = 800, double scale = 1}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accessProvider.overrideWithValue(const Access({'activity.read_all'}, signedIn: true)),
        activityRepositoryProvider.overrideWithValue(repo),
        enumCatalogProvider.overrideWith((ref) async => EnumCatalog.empty),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: ActivityLogSection(entity: ActivityEntity.patientProfile, id: 'p1'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _sentence(String text) => find.textContaining(text, findRichText: true);

void main() {
  test('a row maps the server fields, old and new included', () {
    final row = ActivityEntry.fromJson({
      'id': 'a1',
      'action': 'updated',
      'action_label': 'Edited',
      'entity': 'patient_profile',
      'changes': [
        {'field': 'email', 'label': 'Email', 'old': 'a@x.com', 'new': 'b@x.com'},
      ],
      'changed_by': null,
      'created_at': '2026-11-08T15:27:00Z',
    });
    expect(row.actionLabel, 'Edited');
    expect(row.changedBy, isNull);
    expect(row.changes.single.oldValue, 'a@x.com');
    expect(row.changes.single.newValue, 'b@x.com');
  });

  test('changes read as plain phrases', () {
    const edited = ActivityChange(field: 'email', label: 'Email', oldValue: 'a@x.com', newValue: 'b@x.com');
    const filled = ActivityChange(field: 'phone', label: 'Phone', newValue: 3333);
    const emptied = ActivityChange(field: 'notes', label: 'Notes', oldValue: 'Old', newValue: '');
    expect(describeActivityChanges(const [edited]), 'Email from a@x.com to b@x.com');
    expect(describeActivityChanges(const [filled, emptied]), 'Phone set to 3333; Notes cleared (was Old)');
    expect(describeActivityChanges(const []), '');
  });

  test('opening a page has its own badge colour', () {
    expect(StatusColors.tone('AuditAction', 'viewed'), isNot(StatusColors.tone('AuditAction', 'updated')));
    expect(StatusColors.tone('AuditAction', 'viewed'), isNot(StatusTone.grey));
  });

  testWidgets('one sentence per event with only the action as a badge', (tester) async {
    final edit = _entry(1, by: 'Rana Saleh', action: 'updated', label: 'Edited').copyWith(
      changes: const [ActivityChange(field: 'email', label: 'Email', oldValue: 'a@x.com', newValue: 'b@x.com')],
    );
    await _pump(
      tester,
      _FakeActivity({
        null: _page([_entry(0), edit]),
      }),
    );

    expect(_sentence('Amal Haddad'), findsOneWidget);
    expect(_sentence('8 Nov 2026, 6:27 PM'), findsNWidgets(2));
    expect(_sentence('Email from a@x.com to b@x.com'), findsOneWidget);
    expect(find.text('Opened the page'), findsOneWidget);
    expect(find.text('Edited'), findsOneWidget);
    expect(find.byType(StatusChip), findsNWidgets(2));
    expect(find.byType(AppCollapse), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('shows three, keeps the rest in the collapse and loads the next cursor', (tester) async {
    final repo = _FakeActivity({
      null: _page([for (var i = 0; i < 5; i++) _entry(i)], next: 'c2'),
      'c2': _page([_entry(5)]),
    });
    await _pump(tester, repo);

    expect(find.byType(StatusChip), findsNWidgets(3));
    expect(find.text('2+ more events'), findsOneWidget);

    await tester.tap(find.text('2+ more events'));
    await tester.pumpAndSettle();
    expect(find.byType(StatusChip), findsNWidgets(5));

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(repo.cursors, [null, 'c2']);
    expect(find.byType(StatusChip), findsNWidgets(6));
    expect(find.text('3 more events'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('a short first page can still load more; a failure keeps the rows and offers a retry', (tester) async {
    final repo = _FakeActivity({
      null: _page([_entry(0)], next: 'c2'),
    });
    await _pump(tester, repo);
    expect(find.byType(AppCollapse), findsNothing);

    repo.failure = Exception('boom');
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.byType(StatusChip), findsOneWidget);
    expect(find.text('Could not load more — try again'), findsOneWidget);
  });

  testWidgets('empty and error states', (tester) async {
    await _pump(tester, _FakeActivity({null: _page(const [])}));
    expect(find.text('No events yet.'), findsOneWidget);

    await _pump(tester, _FakeActivity({})..failure = Exception('boom'));
    expect(find.byType(ErrorState), findsOneWidget);
  });

  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets('long text wraps on a small phone at text scale $scale', (tester) async {
      final long = 'x' * 300;
      final row = _entry(0, by: 'A very long staff member name that goes on and on and on').copyWith(
        changes: [ActivityChange(field: 'notes', label: 'Front-desk notes', oldValue: long, newValue: '$long y')],
      );
      await _pump(
        tester,
        _FakeActivity({
          null: _page([row]),
        }),
        width: 320,
        scale: scale,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('each page has its own audience', (tester) async {
    Future<void> pump(Set<String> rights) => tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          accessProvider.overrideWithValue(Access(rights, signedIn: true)),
          activityRepositoryProvider.overrideWithValue(
            _FakeActivity({
              null: _page([_entry(0)]),
            }),
          ),
          enumCatalogProvider.overrideWith((ref) async => EnumCatalog.empty),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ActivityLogSection(entity: ActivityEntity.appointment, id: 'a1'),
            ),
          ),
        ),
      ),
    );

    await pump({'appointments.read_all'});
    await tester.pumpAndSettle();
    expect(find.text('Event log'), findsOneWidget);

    await pump({'activity.read_all', 'appointments.read_own'});
    await tester.pumpAndSettle();
    expect(find.text('Event log'), findsNothing);
  });

  group('on the patient file', () {
    Future<_FakeActivity> open(WidgetTester tester, Set<String> rights) async {
      final repo = _FakeActivity({
        null: _page([_entry(0)]),
      });
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessProvider.overrideWithValue(Access(rights, signedIn: true)),
            activityRepositoryProvider.overrideWithValue(repo),
            patientRepositoryProvider.overrideWithValue(_FakePatients()),
            enumCatalogProvider.overrideWith((ref) async => EnumCatalog.empty),
          ],
          child: const MaterialApp(home: PatientDetailScreen(id: 'p1')),
        ),
      );
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('shown with the right', (tester) async {
      final repo = await open(tester, {'activity.read_all'});
      expect(find.text('Event log'), findsOneWidget);
      expect(repo.cursors, [null]);
    });

    testWidgets('hidden and not fetched without it', (tester) async {
      final repo = await open(tester, {'patients.read_all'});
      expect(find.text('Event log'), findsNothing);
      expect(repo.cursors, isEmpty);
    });
  });
}
