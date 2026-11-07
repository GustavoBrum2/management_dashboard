import 'package:flutter/material.dart';

import 'data/parts_repository.dart';
import 'data/twins_repository.dart';
import 'screens/dashboard_shell.dart';
import 'state/dashboard_controller.dart';
import 'state/dashboard_scope.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ManagementDashboardApp());
}

class ManagementDashboardApp extends StatefulWidget {
  const ManagementDashboardApp({super.key, this.twinsRepository, this.partsRepository});

  final TwinsRepository? twinsRepository;
  final PartsRepository? partsRepository;

  @override
  State<ManagementDashboardApp> createState() => _ManagementDashboardAppState();
}

class _ManagementDashboardAppState extends State<ManagementDashboardApp> {
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = DashboardController(twinsRepository: widget.twinsRepository ?? FirebaseTwinsRepository(), partsRepository: widget.partsRepository ?? AssetPartsRepository())..loadTwins();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScope(
      controller: controller,
      child: MaterialApp(title: 'PC Match', debugShowCheckedModeBanner: false, theme: AppTheme.dark, home: const DashboardShell()),
    );
  }
}
