import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mcnd_mobile/core/utils/indexed_iterable.dart';
import 'package:mcnd_mobile/di/providers.dart';
import 'package:mcnd_mobile/main.dart';
import 'package:mcnd_mobile/services/shared_pref_manager.dart';
import 'package:mcnd_mobile/services/theme_manager.dart';
import 'package:mcnd_mobile/ui/settings/settings_model.dart';
import 'package:mcnd_mobile/ui/shared/hooks/use_once.dart';
import 'package:mcnd_mobile/ui/shared/utils/separated_widget_list.dart';

class SettingsScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(settingsViewModelProvider);
    useOnce(() => viewModel.load());
    final state = useProvider(settingsViewModelProvider.state);
    final count = useProvider(themeProvider);
    print("///////////////");
    print(count);
    print(count.getFontSize());
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'Azan Settings',
          maxLines: 1,
          maxFontSize: 30,
          minFontSize: 15,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state == null) {
            return Container();
          }
          return ListView(
            children: [
              const SettingsHeader(text: 'Azan Notifications'),
              ...state.azanSettingsItems
                  .map((e) => SettingsItem(
                item: e,
                options: state.azanSettingsOptions,
              ))
                  .toList()
                  .separatedByDivider(),
              const SizedBox(height: 50),
              const SettingsHeader(text: 'App Settings'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Azan Times Font Size',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(width: 12),
                    const Spacer(),
                    DropdownButton<AppFontSize>(
                      underline: const SizedBox(),
                      value: count.getFontSize(),
                      items: AppFontSize.values.map((e) => DropdownMenuItem<AppFontSize>(
                        value: e,
                        child: Text(
                          e.name,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      )).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        count.changeFontSize(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SettingsHeader extends StatelessWidget {
  final String text;

  const SettingsHeader({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0).copyWith(bottom: 0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff818181),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SettingsItem extends HookWidget {
  final AzanSettingsItem item;
  final List<String> options;

  const SettingsItem({
    required this.item,
    required this.options,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(settingsViewModelProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            item.salahName,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(width: 12),
          const Spacer(),
          DropdownButton<int>(
            underline: const SizedBox(),
            value: item.selectedSetting,
            items: options
                .mapIndexed(
                  (i, e) => DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      options[i],
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              viewModel.changeAzanSettings(item.salah, value);
            },
          ),
        ],
      ),
    );
  }
}
