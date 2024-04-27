import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mcnd_mobile/main.dart';
import 'package:mcnd_mobile/ui/mcnd_router.gr.dart';

class McndApp extends ConsumerWidget {
  final _router = McndRouter();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final baseTheme = ThemeData.light();
    final theme = baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        iconTheme: baseTheme.iconTheme.copyWith(
          color: Colors.black,
        ),
        textTheme: baseTheme.textTheme.apply(
          displayColor: Colors.black,
        ),
        elevation: 8,
        backgroundColor: Colors.white,
      ),
    );

    return MaterialApp.router(
      title: 'MCND Mosque',
      theme: theme,
      routerDelegate: _router.delegate(),
      routeInformationParser: _router.defaultRouteParser(),
      debugShowCheckedModeBanner: false,
    );
  }

}
