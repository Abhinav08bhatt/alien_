import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';

import '../models/alien_apps.dart';

final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  return StoreNotifier();
});

class StoreState {
  final List<CraftApp> apps;
  final String searchQuery;
  final String sortMode;
  final bool isLoading;

  StoreState({
    required this.apps,
    this.searchQuery = '',
    this.sortMode = 'Name (A–Z)',
    this.isLoading = false,
  });

  StoreState copyWith({
    List<CraftApp>? apps,
    String? searchQuery,
    String? sortMode,
    bool? isLoading,
  }) {
    return StoreState(
      apps: apps ?? this.apps,
      searchQuery: searchQuery ?? this.searchQuery,
      sortMode: sortMode ?? this.sortMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StoreNotifier extends StateNotifier<StoreState> {
  StoreNotifier() : super(StoreState(apps: _initialData)) {
    refreshInstalledStatus();
  }

  static final List<CraftApp> _initialData = [
    const CraftApp(
      id: 'music',
      packageName: 'com.artcraft.music',
      name: 'SoundCraft',
      tagLine: 'Recording, editing and mixing audio',
      description: 'Record, edit and mix your audio. Built for speed and custom workflow.',
      version: 'V0.16.0',
      versionCode: 16,
      lastUpdated: 'Nov 2, 2026',
      githubUrl: 'https://github.com',
      apkDownloadUrl: 'https://github.com',
      accentColor: Color(0xFF00E676),
      icon: Icons.graphic_eq_rounded,
    ),
    const CraftApp(
      id: 'movie',
      packageName: 'com.artcraft.movies',
      name: 'FilmCraft',
      tagLine: 'Video curation, color and sound',
      description: 'Professional video editing and movie recommendation system.',
      version: 'V0.20.0',
      versionCode: 20,
      lastUpdated: 'Nov 2, 2026',
      githubUrl: 'https://github.com',
      apkDownloadUrl: 'https://github.com',
      accentColor: Color(0xFFFF4081),
      icon: Icons.movie_creation_outlined,
    ),
    const CraftApp(
      id: 'design',
      packageName: 'com.artcraft.design',
      name: 'DesignCraft',
      tagLine: 'Page layout and publishing',
      description: 'Layout your ideas, print ready posters and graphic suites.',
      version: 'V0.16.0',
      versionCode: 16,
      lastUpdated: 'Nov 2, 2026',
      githubUrl: 'https://github.com',
      accentColor: Color(0xFF69F0AE),
      icon: Icons.auto_awesome_mosaic_outlined,
      apkDownloadUrl: 'https://github.com',
    ),
    const CraftApp(
      id: 'light',
      packageName: 'com.artcraft.photo',
      name: 'LightCraft',
      tagLine: 'Photo library and raw development',
      description: 'Your photos. Your pixels. Your machine. Zero cloud dependency.',
      version: 'V0.17.0',
      versionCode: 17,
      lastUpdated: 'Nov 2, 2026',
      githubUrl: 'https://github.com',
      accentColor: Color(0xFFFFAB00),
      icon: Icons.photo_filter_rounded,
      apkDownloadUrl: 'https://github.com',
    ),
  ];

  Future<void> refreshInstalledStatus() async {
    state = state.copyWith(isLoading: true);
    final List<CraftApp> updated = [];

    for (final app in state.apps) {
      try {
        final AppInfo? info = await InstalledApps.getAppInfo(app.packageName);
        if (info == null) {
          updated.add(app.copyWith(status: AppInstallState.notInstalled));
        } else {
          final int installedCode = info.versionCode ?? 0;
          if (installedCode < app.versionCode) {
            updated.add(app.copyWith(
              status: AppInstallState.updateAvailable,
              installedVersion: info.versionName,
            ));
          } else {
            updated.add(app.copyWith(
              status: AppInstallState.upToDate,
              installedVersion: info.versionName,
            ));
          }
        }
      } catch (_) {
        // Fallback for emulator / permissions
        updated.add(app);
      }
    }

    state = state.copyWith(apps: updated, isLoading: false);
  }

  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void setSort(String sort) => state = state.copyWith(sortMode: sort);

  void openApp(String packageName) {
    InstalledApps.startApp(packageName);
  }

  Future<void> downloadAndInstall(CraftApp app) async {
    _updateAppInState(app.id, (a) => a.copyWith(isDownloading: true, downloadProgress: 0.05));

    try {
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/${app.id}_latest.apk";

      final dio = Dio();
      await dio.download(
        app.apkDownloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _updateAppInState(app.id, (a) => a.copyWith(downloadProgress: progress));
          }
        },
      );

      _updateAppInState(app.id, (a) => a.copyWith(isDownloading: false, downloadProgress: 1.0));
      await InstallPlugin.installApk(filePath, appId: 'com.example.alien_launcher');
      await refreshInstalledStatus();
    } catch (e) {
      _updateAppInState(app.id, (a) => a.copyWith(isDownloading: false, downloadProgress: 0.0));
    }
  }

  void _updateAppInState(String id, CraftApp Function(CraftApp) update) {
    state = state.copyWith(
      apps: state.apps.map((a) => a.id == id ? update(a) : a).toList(),
    );
  }
}