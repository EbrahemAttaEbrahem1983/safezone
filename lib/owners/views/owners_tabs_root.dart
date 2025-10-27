// lib/owners/views/owners_tabs_root.dart
import 'package:flutter/material.dart';
import '../../units/database/app_database.dart';
import '../database/owners_schema.dart';
import 'tab_enter.dart';
import 'tab_exit.dart';
import 'tab_log.dart';
import 'tab_presence.dart';

class OwnersTabsRoot extends StatefulWidget {
  const OwnersTabsRoot({super.key});
  @override
  State<OwnersTabsRoot> createState() => _OwnersTabsRootState();
}

class _OwnersTabsRootState extends State<OwnersTabsRoot> {
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await OwnersSchema.ensure(UnitsDatabase.instance.db);
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تمام الملاك'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'دخول'),
              Tab(text: 'خروج'),
              Tab(text: 'السجل'),
              Tab(text: 'الحضور الآن'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EnterOwnerTab(),
            ExitOwnerTab(),
            OwnersLogTab(),
            PresenceNowTab(),
          ],
        ),
      ),
    );
  }
}
