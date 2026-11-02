import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  final bool isSelfUpdateAvailable;
  final String? selfLatestVersion;
  final String? selfDownloadUrl;
  final bool isSelfUpdating;
  final double selfUpdateProgress;

  StoreState({
    required this.apps,
    this.searchQuery = '',
    this.sortMode = 'Name (A–Z)',
    this.isLoading = false,
    this.isSelfUpdateAvailable = false,
    this.selfLatestVersion,
    this.selfDownloadUrl,
    this.isSelfUpdating = false,
    this.selfUpdateProgress = 0.0,
  });

  StoreState copyWith({
    List<CraftApp>? apps,
    String? searchQuery,
    String? sortMode,
    bool? isLoading,
    bool? isSelfUpdateAvailable,
    String? selfLatestVersion,
    String? selfDownloadUrl,
    bool? isSelfUpdating,
    double? selfUpdateProgress,
  }) {
    return StoreState(
      apps: apps ?? this.apps,
      searchQuery: searchQuery ?? this.searchQuery,
      sortMode: sortMode ?? this.sortMode,
      isLoading: isLoading ?? this.isLoading,
      isSelfUpdateAvailable: isSelfUpdateAvailable ?? this.isSelfUpdateAvailable,
      selfLatestVersion: selfLatestVersion ?? this.selfLatestVersion,
      selfDownloadUrl: selfDownloadUrl ?? this.selfDownloadUrl,
      isSelfUpdating: isSelfUpdating ?? this.isSelfUpdating,
      selfUpdateProgress: selfUpdateProgress ?? this.selfUpdateProgress,
    );
  }
}

class StoreNotifier extends StateNotifier<StoreState> {
  static const String _githubRepo = 'Abhinav08bhatt/alien_';

  StoreNotifier() : super(StoreState(apps: _initialData)) {
    refreshInstalledStatus();
  }

  static final List<CraftApp> _initialData = [
    const CraftApp(
      id: 'music',
      packageName: 'com.alien.music_',
      name: 'music',
      tagLine: 'Recording, editing and mixing audio',
      description: 'Record, edit and mix your audio. Built for speed and custom workflow.',
      version: 'v0.0.1',
      versionCode: 1,
      lastUpdated: 'Recently',
      githubUrl: 'https://github.com/Abhinav08bhatt/alien_',
      apkDownloadUrl: '',
      accentColor: Color(0xFF0095FF),
      icon: 'assets/icons/music_.png',
      tagPrefix: 'musicv', // Matches: musicv0.0.1, musicv0.0.2, etc.
    ),
  ];

  /// Checks both the Launcher's own update AND all apps' updates from GitHub
  Future<void> refreshInstalledStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      // 1. Fetch releases from your shared GitHub repository
      final dio = Dio();
      final response = await dio.get(
        'https://api.github.com/repos/$_githubRepo/releases?per_page=30',
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      final List<dynamic> releases = response.data is List ? response.data : [];

      // 2. Check Launcher Self-Update (tags starting with 'v' like v0.0.1, v0.0.2)
      await _checkLauncherSelfUpdate(releases);

      // 3. Check App Updates from the releases list
      final List<CraftApp> updatedApps = [];

      for (final app in state.apps) {
        CraftApp currentApp = app;

        // Find the newest release matching this app's tagPrefix (e.g., 'musicv')
        final matchingReleases = releases.where((r) {
          final tag = (r['tag_name'] as String? ?? '').toLowerCase();
          return tag.startsWith(app.tagPrefix.toLowerCase());
        }).toList();

        if (matchingReleases.isNotEmpty) {
          // Releases are sorted newest first by GitHub
          final latestRelease = matchingReleases.first;
          final remoteTag = latestRelease['tag_name'] as String? ?? '';
          final remoteVersion = _extractVersionDigits(remoteTag);

          // Find .apk in assets
          String? downloadUrl;
          final assets = latestRelease['assets'] as List<dynamic>? ?? [];
          for (final asset in assets) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            if (name.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'] as String?;
              break;
            }
          }

          currentApp = currentApp.copyWith(
            version: remoteTag,
            apkDownloadUrl: downloadUrl ?? currentApp.apkDownloadUrl,
          );

          // Check device installation status
          final AppInfo? info = await InstalledApps.getAppInfo(app.packageName);
          if (info == null) {
            currentApp = currentApp.copyWith(status: AppInstallState.notInstalled);
          } else {
            final installedVersion = info.versionName ?? '0.0.0';
            if (_isNewerVersion(installedVersion, remoteVersion)) {
              currentApp = currentApp.copyWith(
                status: AppInstallState.updateAvailable,
                installedVersion: installedVersion,
              );
            } else {
              currentApp = currentApp.copyWith(
                status: AppInstallState.upToDate,
                installedVersion: installedVersion,
              );
            }
          }
        } else {
          // Fallback if no matching tag is found on GitHub yet
          final AppInfo? info = await InstalledApps.getAppInfo(app.packageName);
          currentApp = currentApp.copyWith(
            status: info == null ? AppInstallState.notInstalled : AppInstallState.upToDate,
            installedVersion: info?.versionName,
          );
        }

        updatedApps.add(currentApp);
      }

      state = state.copyWith(apps: updatedApps, isLoading: false);
    } catch (e) {
      debugPrint('Error fetching updates from GitHub: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Processes releases for the Launcher itself (Tag starting with 'v', e.g. v0.0.1)
  Future<void> _checkLauncherSelfUpdate(List<dynamic> releases) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentLauncherVersion = packageInfo.version; // from pubspec.yaml

      // Launcher tags start with 'v' and DO NOT start with any app tag prefixes
      final launcherReleases = releases.where((r) {
        final tag = (r['tag_name'] as String? ?? '').toLowerCase();
        final isAppTag = state.apps.any((a) => tag.startsWith(a.tagPrefix.toLowerCase()));
        return !isAppTag && (tag.startsWith('v'));
      }).toList();

      if (launcherReleases.isNotEmpty) {
        final latest = launcherReleases.first;
        final remoteTag = latest['tag_name'] as String? ?? '';
        final remoteVersion = _extractVersionDigits(remoteTag);

        String? downloadUrl;
        final assets = latest['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] as String?;
            break;
          }
        }

        if (_isNewerVersion(currentLauncherVersion, remoteVersion) && downloadUrl != null) {
          state = state.copyWith(
            isSelfUpdateAvailable: true,
            selfLatestVersion: remoteTag,
            selfDownloadUrl: downloadUrl,
          );
        } else {
          state = state.copyWith(isSelfUpdateAvailable: false);
        }
      }
    } catch (e) {
      debugPrint('Launcher self update check error: $e');
    }
  }

  /// Extracts numbers from string (e.g. "musicv0.0.2" -> "0.0.2", "v.0.0.1" -> "0.0.1")
  String _extractVersionDigits(String tag) {
    final match = RegExp(r'(\d+(\.\d+)+)').firstMatch(tag);
    return match != null ? match.group(0)! : '0.0.0';
  }

  /// Compares semantic versions (e.g. "0.0.1" vs "0.0.2")
  bool _isNewerVersion(String current, String remote) {
    try {
      final cParts = _extractVersionDigits(current).split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final rParts = _extractVersionDigits(remote).split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = cParts.length > rParts.length ? cParts.length : rParts.length;
      for (int i = 0; i < maxLen; i++) {
        final c = i < cParts.length ? cParts[i] : 0;
        final r = i < rParts.length ? rParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
    } catch (_) {}
    return false;
  }

  /// Self-updates the Launcher app
  Future<void> updateLauncher() async {
    final url = state.selfDownloadUrl;
    if (url == null || state.isSelfUpdating) return;

    state = state.copyWith(isSelfUpdating: true, selfUpdateProgress: 0.05);

    try {
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/alien_launcher_update.apk";

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            state = state.copyWith(selfUpdateProgress: received / total);
          }
        },
      );

      state = state.copyWith(isSelfUpdating: false, selfUpdateProgress: 1.0);
      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('Error updating launcher: $e');
      state = state.copyWith(isSelfUpdating: false, selfUpdateProgress: 0.0);
    }
  }

  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void setSort(String sort) => state = state.copyWith(sortMode: sort);

  void openApp(String packageName) {
    InstalledApps.startApp(packageName);
  }

  /// Downloads and triggers installation of any app (e.g. music_)
  Future<void> downloadAndInstall(CraftApp app) async {
    if (app.apkDownloadUrl.isEmpty) return;

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
      await OpenFilex.open(filePath);
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