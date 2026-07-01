import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/link_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'presentation/providers/link_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Database (Encrypted Hive)
  final hiveService = HiveService();
  await hiveService.init();

  final router = AppRouter.createRouter(hiveService.hasSeenOnboarding);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: hiveService),
        ChangeNotifierProvider(
          create: (context) => LinkProvider(LinkRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(CategoryRepositoryImpl()),
        ),
      ],
      child: LinkoraApp(router: router),
    ),
  );
}

class LinkoraApp extends StatelessWidget {
  final GoRouter router;
  
  const LinkoraApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Linkora',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
