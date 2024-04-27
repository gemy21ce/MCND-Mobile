import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mcnd_mobile/di/providers.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_wide_screen.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_widget.dart';
import 'package:mcnd_mobile/ui/shared/hooks/use_once.dart';

class PrayerTimesPage extends HookWidget {
  final bool wideScreen;

  const PrayerTimesPage({Key? key, this.wideScreen = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewmodel = useProvider(prayerTimesViewModelProvider);
    useOnce(() => viewmodel.fetchTimes());
    final state = useProvider(prayerTimesViewModelProvider.state);
    return state.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error) => Center(
        child: Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      ),
      loaded: (prayerTimes) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => viewmodel.fetchTimes(force: true),
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: wideScreen ? PrayerTimesWideScreenWidget(prayerTimes) : PrayerTimesWidget(prayerTimes),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
