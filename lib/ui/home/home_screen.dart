import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcnd_mobile/ui/compass_page/compass_page.dart';
import 'package:mcnd_mobile/ui/mcnd_router.gr.dart';
import 'package:mcnd_mobile/ui/news/news_page.dart';
import 'package:mcnd_mobile/ui/prayer_times/prayer_times_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum URLType { external, internal }

@immutable
class _HomeScreenDrawerItems {
  final String title;
  final IconData icon;
  final String routePath;
  final URLType type;

  const _HomeScreenDrawerItems(this.title, {required this.icon, required this.routePath, this.type = URLType.internal});
}

const String mosqueProjectURL = 'https://hicc.ie/contact';
const String donateURL = 'https://www.hicc.ie/donate';
const String aboutUsURL = 'https://www.hicc.ie';

final _drawerItems = [
  const _HomeScreenDrawerItems('Home', icon: Icons.home, routePath: '/'),
  const _HomeScreenDrawerItems('Mosque',
      icon: Icons.info_outline, routePath: mosqueProjectURL, type: URLType.external),
  const _HomeScreenDrawerItems('Donate', icon: Icons.euro, routePath: donateURL, type: URLType.external),
  const _HomeScreenDrawerItems('About Us', icon: Icons.info_outline, routePath: aboutUsURL, type: URLType.external),
  _HomeScreenDrawerItems('Azan Settings', icon: Icons.settings, routePath: const SettingsScreenRoute().path),
  _HomeScreenDrawerItems('Quarn Radio', icon: Icons.radio, routePath: const RadioScreenRoute().path),
];

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> currentPage = useState(0);
    final PageController pageController = usePageController(initialPage: currentPage.value);
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'Hansfield Islamic Cultural Centre',
          maxLines: 1,
          maxFontSize: 30,
          minFontSize: 15,
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          currentPage.value = value;
        },
        children: const [
          PrayerTimesPage(),
          CompassPage(),
          NewsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPage.value,
        onTap: (index) {
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.clockOutline),
            label: 'Prayer Times',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.compass),
            label: 'Compass',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.newspaper),
            label: 'News',
          ),
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              ..._drawerItems.map(
                (e) => InkWell(
                  onTap: () async {
                    if (e.routePath == '/') {
                      AutoRouter.of(context).pop(); // close the drawer
                      return;
                    }
                    if (e.type == URLType.internal) {
                      AutoRouter.of(context).pop(); // close the drawer
                      AutoRouter.of(context).pushPath(e.routePath);
                    } else {
                      await canLaunch(e.routePath)
                          ? await launch(e.routePath)
                          : throw 'Could not launch ${e.routePath}';
                    }
                  },
                  child: ListTile(
                    title: Text(e.title),
                    leading: Icon(e.icon),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  AutoRouter.of(context).pop(); // close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute<PrayerTimesPage>(
                      builder: (context) => const Scaffold(body: SafeArea(child: PrayerTimesPage(wideScreen: true))),
                    ),
                  );
                },
                child: const ListTile(
                  title: Text('Wide Screen'),
                  leading: Icon(Icons.tv),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
