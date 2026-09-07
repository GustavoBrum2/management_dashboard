import 'package:flutter/material.dart';

import '../state/dashboard_controller.dart';

class DashboardScope extends InheritedNotifier<DashboardController> {
  const DashboardScope({
    required DashboardController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static DashboardController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DashboardScope>();
    assert(scope != null, 'DashboardScope not found');
    return scope!.notifier!;
  }
}
