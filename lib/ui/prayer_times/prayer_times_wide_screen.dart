import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mcnd_mobile/di/providers.dart';
import 'package:mcnd_mobile/gen/assets.gen.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_model.dart';
import 'package:mcnd_mobile/ui/shared/styles/app_colors.dart';

import 'clock_widget.dart';

class PrayerTimesWideScreenWidget extends HookWidget {
  final PrayerTimesModelData viewData;

  const PrayerTimesWideScreenWidget(this.viewData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = useProvider(prayerTimesViewModelProvider);
    useEffect(() {
      vm.startTicker();
      return () => vm.stopTicker();
    }, []);
    final rows = [
      buildItemRow(
        const PrayerTimesModelItem(prayerName: 'Prayer', azan: 'Azan', iqamah: 'Iqamah'),
        color: AppColors.prayerTimeHerderColor,
        topRow: true,
      ),
      ...viewData.times.where((element) => element.iqamah != null).map(
            (time) => buildItemRow(
              time,
              color: !time.highlight ? null : AppColors.upcomingPrayerColor,
              bottomRow: time == viewData.times.last,
            ),
          )
    ];
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: size.height * 0.05,
              ),
              child: Assets.images.logoLarge.image(),
            ),
          ),
          const ClockWidget(),
          SizedBox(height: size.height * 0.07),
          Text(
            viewData.timeToUpcomingIqamah != null
                ? '${viewData.timeToUpcomingIqamah!.isEmpty ? '' : 'Time To '}'
                    '${viewData.upcommingIqamah}'
                : '${viewData.timeToUpcommingSalah.isEmpty ? '' : 'Time To '}'
                    '${viewData.upcommingSalah}',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.07,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            viewData.timeToUpcomingIqamah ?? viewData.timeToUpcommingSalah,
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.07),
          ),
          SizedBox(height: size.height * 0.05),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: size.width * (2.5 / 1000)),
            child: Column(
              children: [
                const Text(
                  'PRAYER TIME',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(size.width * 0.025).copyWith(top: 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.prayerTimeHerderColor),
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          viewData.date,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          viewData.hijriDate,
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 10),
                        DefaultTextStyle.merge(
                          textAlign: TextAlign.center,
                          child: Column(
                            children: rows,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildItemRow(
    PrayerTimesModelItem item, {
    Color? color,
    bool topRow = false,
    bool bottomRow = false,
  }) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: color == null ? Colors.black : Colors.white),
      child: Container(
        color: color,
        child: Row(
          children: [
            buildCell(
              item.prayerName,
              topRow: topRow,
              bottomRow: bottomRow,
              firstCol: true,
            ),
            buildCell(
              item.azan,
              twoCols: item.iqamah == null,
              topRow: topRow,
              bottomRow: bottomRow,
              lastCol: item.iqamah == null,
            ),
            if (item.iqamah != null)
              buildCell(
                item.iqamah!,
                topRow: topRow,
                bottomRow: bottomRow,
                lastCol: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildCell(
    String text, {
    bool twoCols = false,
    bool topRow = false,
    bool bottomRow = false,
    bool firstCol = false,
    bool lastCol = false,
  }) {
    const border = BorderSide(color: AppColors.prayerTimeHerderColor);
    return Expanded(
      flex: twoCols ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            left: firstCol ? BorderSide.none : border,
            top: border,
          ),
        ),
        child: AutoSizeText(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
