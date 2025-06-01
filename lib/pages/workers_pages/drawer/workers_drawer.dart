import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/models/workers.dart';
import 'package:handy_home2/pages/workers_pages/drawer/worker_logout.dart';
import 'package:handy_home2/pages/workers_pages/drawer/workers_contact_us.dart';
import 'package:handy_home2/pages/workers_pages/drawer/workers_orders.dart';
import 'package:handy_home2/pages/workers_pages/drawer/workers_settings.dart';
import 'package:handy_home2/pages/workers_pages/edit_worker_profile.dart';
import 'package:handy_home2/pages/workers_pages/worker_home_page.dart';

class WorkersDrawer extends StatelessWidget {
  final WorkerProfile worker;

  const WorkersDrawer({super.key, required this.worker});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Text(
              'menu'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 40,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('home_page'.tr),
            onTap: () => navigateToPage(context, const WorkerHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('settings'.tr),
            onTap: () => navigateToPage(context, const WorkersSettings()),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('profile'.tr),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWorkerProfilePage(worker: worker),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cases),
            title: Text('orders'.tr),
            onTap: () => navigateToPage(context, WorkerOrdersPage()),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: Text('contact_us'.tr),
            onTap: () => navigateToPage(context, const WorkersContactUs()),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('logout'.tr),
            onTap: () => navigateToPage(context, const WorkerLogout()),
          ),
        ],
      ),
    );
  }
}
