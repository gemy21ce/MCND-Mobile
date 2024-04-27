import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_times_model.freezed.dart';

@freezed
class PrayerTimesModel with _$PrayerTimesModel {
  const factory PrayerTimesModel.loading() = Loading;
  const factory PrayerTimesModel.error(String error) = Error;
  const factory PrayerTimesModel.loaded(PrayerTimesModelData data) = Loaded;
}

@freezed
class PrayerTimesModelData with _$PrayerTimesModelData {
  const factory PrayerTimesModelData({
    required String date,
    required String hijriDate,
    required String upcommingSalah,
    required String timeToUpcommingSalah,
    required String upcommingIqamah,
    String? timeToUpcomingIqamah,
    required List<PrayerTimesModelItem> times,
  }) = _PrayerTimesModelData;
}

@freezed
class PrayerTimesModelItem with _$PrayerTimesModelItem {
  const factory PrayerTimesModelItem({
    required String prayerName,
    required String azan,
    String? iqamah,
    @Default(false) bool highlight,
  }) = _PrayerTimesModelItem;
}
