import 'dart:async';

import 'package:clock/clock.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mcnd_mobile/core/utils/datetime_utils.dart';
import 'package:mcnd_mobile/core/utils/duration_utils.dart';
import 'package:mcnd_mobile/data/models/app/day_prayer.dart';
import 'package:mcnd_mobile/data/models/app/salah.dart';
import 'package:mcnd_mobile/services/azan_times_service.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_model.dart';
import 'package:meta/meta.dart';

@injectable
class PrayerTimesViewModel extends StateNotifier<PrayerTimesModel> {
  final AzanTimesService _azanTimesService;
  final Logger _logger;
  final Clock _clock;

  final _timeFormat = DateFormat('h:mm a');
  final _dateFormat = DateFormat('MMMM dd, yyyy');
  final _hijriDatePattern = 'dd MMMM yyyy';
  final _tickerDuration = const Duration(seconds: 30);

  Timer? _ticker;
  DayPrayers? _prayerTime;

  PrayerTimesViewModel(this._azanTimesService, this._logger, this._clock)
      : super(const PrayerTimesModel.loading());

  Future<void> fetchTimes({bool force = false}) async {
    if (!force && state is Loaded) return;
    state = const PrayerTimesModel.loading();
    try {
      _prayerTime = await _azanTimesService
          .fetchTodayPrayersAndScheduleAheadNotifications();
      state = PrayerTimesModel.loaded(_toModelData());
    } catch (e, stk) {
      _logger.e('Failed to fetch prayer times', e, stk);
      state = PrayerTimesModel.error(e.toString());
    }
  }

  void startTicker() {
    _ticker = Timer.periodic(_tickerDuration, (_) {
      if (state is Loaded) {
        if (_prayerTime?.times[Salah.isha]?.iqamah != null &&
            _clock.now().isAfter(_prayerTime!.times[Salah.isha]!.iqamah!)) {
          fetchTimes(force: true);
        } else {
          state = PrayerTimesModel.loaded(_toModelData());
        }
      } else {
        _prayerTime = null;
        stopTicker();
      }
    });
  }

  void stopTicker() {
    _ticker?.cancel();
  }

  PrayerTimesModelData _toModelData() {
    final DateTime now = _clock.now();
    final DayPrayers _prayerTime = this._prayerTime!;
    final dateString = _prayerTime.date.format(_dateFormat);
    final hijriDateString =
        HijriCalendar.fromDate(_prayerTime.date).toFormat(_hijriDatePattern);

    final upcomingSalah = nearestSalah(_prayerTime, now);
    final upcomingSalahString = upcomingSalah.getStringName().toUpperCase();

    final upcomingSalahTime = _prayerTime.times[upcomingSalah]!;
    final upcomingDateTime = upcomingSalahTime.azan;
    final timeToUpcomingSalah =
        upcomingDateTime.difference(now).getTimeDifferenceString(
              seconds: false,
            );
    final upcomingIqamah = nearestIqamah(_prayerTime, now, upcomingDateTime);
    final upcomingIqamahString =
        '${upcomingIqamah?.getStringName().toUpperCase()} Iqamah';
    String? timeToUpcomingIqamah;
    if (upcomingIqamah != null) {
      timeToUpcomingIqamah =
        _prayerTime.times[upcomingIqamah]!.iqamah!.difference(now).getTimeDifferenceString(
                  seconds: false,
                );
    }

    final items = _prayerTime.times.entries.map((e) {
      final salah = e.key;
      final time = e.value;
      final highlight = salah == upcomingSalah;
      return PrayerTimesModelItem(
        prayerName: salah.getStringName(),
        azan: time.azan.format(_timeFormat),
        iqamah: time.iqamah?.format(_timeFormat),
        highlight: highlight,
      );
    }).toList();

    return PrayerTimesModelData(
      date: dateString,
      hijriDate: hijriDateString,
      upcommingSalah: upcomingSalahString,
      timeToUpcommingSalah: timeToUpcomingSalah,
      upcommingIqamah: upcomingIqamahString,
      timeToUpcomingIqamah: timeToUpcomingIqamah,
      times: items,
    );
  }

  @visibleForTesting
  Salah nearestSalah(DayPrayers prayerTime, DateTime forTime) {
    final times = prayerTime.times.entries.toList()
      ..sort((a, b) {
        return a.value.azan.compareTo(b.value.azan);
      });
    for (final t in times) {
      if (t.value.azan.isAfter(forTime)) {
        return t.key;
      }
    }
    return times.last.key;
  }

  Salah? nearestIqamah(DayPrayers prayerTime, DateTime forTime, DateTime upcomingSalahTime) {
    // final times = prayerTime.times.entries.toList()
    //   ..sort((a, b) {
    //     return a.value.iqamah?.compareTo(b.value.iqamah) ?? -1;
    //   });
    for (final t in prayerTime.times.entries) {
      if (t.value.iqamah?.isAfter(forTime) ?? false) {
        if (t.key == Salah.isha && t.value.azan.isBefore(forTime)) {
          return t.key;
        }
        if (t.value.iqamah!.isBefore(upcomingSalahTime)) {
          return t.key;
        }
      }
    }
    return null;
  }
}
