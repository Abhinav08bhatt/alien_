import 'package:flutter/material.dart';

enum AppInstallState { notInstalled, upToDate, updateAvailable }

class CraftApp {
  final String id;
  final String packageName;
  final String name;
  final String publisher;
  final String tagLine;
  final String description;
  final String version;
  final int versionCode;
  final String lastUpdated;
  final String githubUrl;
  final String apkDownloadUrl;
  final Color accentColor;
  final IconData icon;

  // Local state
  final AppInstallState status;
  final String? installedVersion;
  final double downloadProgress;
  final bool isDownloading;

  const CraftApp({
    required this.id,
    required this.packageName,
    required this.name,
    this.publisher = 'BY ALIEN',
    required this.tagLine,
    required this.description,
    required this.version,
    required this.versionCode,
    required this.lastUpdated,
    required this.githubUrl,
    required this.apkDownloadUrl,
    required this.accentColor,
    required this.icon,
    this.status = AppInstallState.notInstalled,
    this.installedVersion,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
  });

  CraftApp copyWith({
    AppInstallState? status,
    String? installedVersion,
    double? downloadProgress,
    bool? isDownloading,
  }) {
    return CraftApp(
      id: id,
      packageName: packageName,
      name: name,
      publisher: publisher,
      tagLine: tagLine,
      description: description,
      version: version,
      versionCode: versionCode,
      lastUpdated: lastUpdated,
      githubUrl: githubUrl,
      apkDownloadUrl: apkDownloadUrl,
      accentColor: accentColor,
      icon: icon,
      status: status ?? this.status,
      installedVersion: installedVersion ?? this.installedVersion,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}