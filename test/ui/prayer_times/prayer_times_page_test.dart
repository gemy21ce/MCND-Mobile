import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mcnd_mobile/di/providers.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_model.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_page.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_viewmodel.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_widget.dart';
import 'package:mockito/annotations.dart';

import 'prayer_times_page_test.mocks.dart';

extension on WidgetTester {
  Future<void> pumpPrayerTimesPage({
    List<Override> providerOverrides = const [],
    List<ProviderObserver>? observers,
  }) async {
    await pumpWidget(ProviderScope(
      overrides: providerOverrides,
      observers: observers,
      child: const MaterialApp(
        home: PrayerTimesPage(),
      ),
    ));
  }
}

@GenerateMocks([], customMocks: [
  MockSpec<PrayerTimesViewModel>(
    returnNullOnMissingStub: true,
  ),
])
void main() {
  group('PrayerTimesPage', () {
    testWidgets('will show loading when state is loading', (tester) async {
      final vm = MockPrayerTimesViewModel();
      const state = PrayerTimesModel.loading();
      await tester.pumpPrayerTimesPage(providerOverrides: [
        prayerTimesViewModelProvider.overrideWithValue(vm),
        prayerTimesViewModelProvider.state.overrideWithValue(state)
      ]);

      await tester.pump();

      final loading = find.byWidgetPredicate((widget) => widget is CircularProgressIndicator);

      expect(loading, findsOneWidget);
    });

    testWidgets('will show error string when state is error', (tester) async {
      final vm = MockPrayerTimesViewModel();
      const errorString = 'This should be an error';
      const state = PrayerTimesModel.error(errorString);
      await tester.pumpPrayerTimesPage(providerOverrides: [
        prayerTimesViewModelProvider.overrideWithValue(vm),
        prayerTimesViewModelProvider.state.overrideWithValue(state)
      ]);

      await tester.pump();

      final result = find.text(errorString);
      final Text errorWidget = tester.firstWidget(result) as Text;

      expect(result, findsOneWidget);
      expect(errorWidget.style?.color, Colors.red);
    });

    testWidgets('will show PrayerTimesWidget if state is loaded', (tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
      await binding.setSurfaceSize(const Size(1080, 1920)); // set with bigger size

      final vm = MockPrayerTimesViewModel();
      const state = PrayerTimesModel.loaded(PrayerTimesModelData(
        times: [],
        date: '',
        timeToUpcommingSalah: '',
        upcommingSalah: '',
        upcommingIqamah: '',
        hijriDate: '',
      ));
      await tester.pumpPrayerTimesPage(providerOverrides: [
        prayerTimesViewModelProvider.overrideWithValue(vm),
        prayerTimesViewModelProvider.state.overrideWithValue(state)
      ]);

      await tester.pump();

      final result = find.byWidgetPredicate((widget) => widget is PrayerTimesWidget);

      expect(result, findsOneWidget);
    });
  });
}
