import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @lazySingleton
  Dio get httpClient {
    final dio = Dio();

    dio.options.baseUrl = 'https://sdic.ie/wp-json/';

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger());
    }

    return dio;
  }

  @singleton
  Clock get clock => const Clock();

  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  @lazySingleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @singleton
  Logger getLogger() {
    return Logger(printer: _PrefixPrinter(PrettyPrinter(colors: false)));
  }
}

class _PrefixPrinter extends LogPrinter {
  final LogPrinter _realPrinter;
  final Map<Level, String> _prefixMap;

  _PrefixPrinter(
    this._realPrinter, {
    String? debug,
    String? verbose,
    String? wtf,
    String? info,
    String? warning,
    String? error,
    String? nothing,
  })  : _prefixMap = {
          Level.debug: debug ?? '  DEBUG ',
          Level.verbose: verbose ?? 'VERBOSE ',
          Level.wtf: wtf ?? '    WTF ',
          Level.info: info ?? '   INFO ',
          Level.warning: warning ?? 'WARNING ',
          Level.error: error ?? '  ERROR ',
          Level.nothing: nothing ?? 'NOTHING',
        },
        super();

  @override
  List<String> log(LogEvent event) {
    return _realPrinter
        .log(event)
        .map((s) => '${_prefixMap[event.level]}$s')
        .toList();
  }
}
