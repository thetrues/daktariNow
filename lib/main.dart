import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';

void main() {
  // Clean web URLs (/doctor/schedule instead of /#/doctor/schedule), and
  // keep the address bar in sync with pushed pages so links can be shared.
  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const ProviderScope(child: DaktariNowApp()));
}
