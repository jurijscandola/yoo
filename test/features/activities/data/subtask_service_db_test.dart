import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/time/clock.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/features/activities/data/drift_subtask_repository.dart';
import 'package:yoo/features/activities/domain/services/subtask_service.dart';

import '../../../helpers/fixtures.dart';

void main() {
  late AppDatabase db;
  late DriftSubtaskRepository repo;
  late SubtaskService service;
  final today = LocalDate(2026, 9, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSubtaskRepository(db);
    service = SubtaskService(
      subtasks: repo,
      clock: FixedClock(DateTime(2026, 9, 30, 10)),
      newId: sequentialIds('s'),
    );
  });

  tearDown(() => db.close());

  test('subtasks are added in order and blank titles are ignored', () async {
    await service.add('a', ' Lavare ');
    await service.add('a', '   ');
    await service.add('a', 'Asciugare');
    await service.add('b', 'Other activity');
    final list = await repo.getForActivity('a');
    expect(list.map((s) => s.title), ['Lavare', 'Asciugare']);
    expect(list.map((s) => s.position), [0, 1]);
  });

  test('checks are per day and go away with the subtask', () async {
    final wash = (await service.add('a', 'Lavare'))!;
    final dry = (await service.add('a', 'Asciugare'))!;
    await service.setChecked(wash, today, checked: true);
    await service.setChecked(dry, today, checked: true);
    await service.setChecked(dry, today, checked: false);
    expect(await repo.watchChecked('a', today).first, {wash.id});
    expect(await repo.watchChecked('a', today.addDays(7)).first, isEmpty);

    await service.delete(wash);
    expect(await repo.watchChecked('a', today).first, isEmpty);
    expect((await repo.getForActivity('a')).map((s) => s.title), ['Asciugare']);
  });

  test('rename keeps the old title when the new one is blank', () async {
    final s = (await service.add('a', 'Lavare'))!;
    await service.rename(s, '  ');
    await service.rename(s, 'Lavare bene');
    expect((await repo.getForActivity('a')).single.title, 'Lavare bene');
  });
}
