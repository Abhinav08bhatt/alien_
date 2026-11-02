import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/launcher_controller.dart';
import 'models/alien_apps.dart';
import 'theme/app_theme.dart';
import 'widgets/app_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.black,
  ));
  runApp(const ProviderScope(child: AlienLauncherApp()));
}

class AlienLauncherApp extends StatelessWidget {
  const AlienLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALIEN LAUNCHER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.black,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.textMain,
          surface: AppColors.surface,
        ),
      ),
      home: const StoreHomeScreen(),
    );
  }
}

class StoreHomeScreen extends ConsumerWidget {
  const StoreHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeProvider);
    final notifier = ref.read(storeProvider.notifier);

    final filteredApps = state.apps.where((a) {
      final matchesSearch = a.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          a.description.toLowerCase().contains(state.searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    final installedApps = filteredApps.where((a) => a.status != AppInstallState.notInstalled).toList();
    final notInstalledApps = filteredApps.where((a) => a.status == AppInstallState.notInstalled).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ================== TOP HEADER BAR ==================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  const Text(
                    'ALIEN',
                    style: TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'APP LAUNCHER',
                    style: TextStyle(
                      fontFamily: AppFonts.digital,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),

                  // ================== SELF UPDATE BUTTON ==================
                  if (state.isSelfUpdateAvailable) ...[
                    InkWell(
                      onTap: notifier.updateLauncher,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.12),
                          border: Border.all(color: Colors.amberAccent, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.system_update_alt_rounded,
                              size: 13,
                              color: Colors.amberAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'UPDATE v${state.selfLatestVersion ?? ''}',
                              style: const TextStyle(
                                fontFamily: AppFonts.digital,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ================== CONTROLS & SEARCH BAR ==================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: notifier.refreshInstalledStatus,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight, width: 1.2),
                      ),
                      child: state.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, color: AppColors.textSub, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        onChanged: notifier.setSearch,
                        style: const TextStyle(
                          fontFamily: AppFonts.primary,
                          fontSize: 13,
                          color: AppColors.textMain,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search apps',
                          hintStyle: const TextStyle(
                            fontFamily: AppFonts.primary,
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                          filled: true,
                          fillColor: AppColors.cardBg,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.borderLight, width: 1.2),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.badgeText, width: 1.2),
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================== APP LIST ==================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (final app in installedApps)
                    AppCard(
                      app: app,
                      onAction: () => app.status == AppInstallState.upToDate
                          ? notifier.openApp(app.packageName)
                          : notifier.downloadAndInstall(app),
                    ),
                  if (notInstalledApps.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          const Text(
                            'NOT INSTALLED',
                            style: TextStyle(
                              fontFamily: AppFonts.digital,
                              fontSize: 11,
                              color: AppColors.textMuted,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(height: 1, color: AppColors.border),
                          ),
                        ],
                      ),
                    ),
                    for (final app in notInstalledApps)
                      AppCard(
                        app: app,
                        onAction: () => notifier.downloadAndInstall(app),
                      ),
                  ],
                ],
              ),
            ),

            // ================== TECHNICAL FOOTER ==================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                color: AppColors.cardBg,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHECKED 2 MIN AGO • USING ALIEN API AND GITHUB',
                    style: TextStyle(
                      fontFamily: AppFonts.digital,
                      fontSize: 9,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(Icons.terminal_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}