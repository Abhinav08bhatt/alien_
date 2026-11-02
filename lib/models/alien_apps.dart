import 'package:flutter/material.dart';

enum AppInstallState {
  notInstalled,
  updateAvailable,
  upToDate,
}

class CraftApp {
  final String id;
  final String packageName;
  final String name;
  final String tagLine;
  final String description;
  final String version;
  final int versionCode;
  final String lastUpdated;
  final String githubUrl;
  final String apkDownloadUrl;
  final Color accentColor;
  final String icon;
  final String tagPrefix; // e.g., 'musicv' for music app

  final AppInstallState status;
  final String? installedVersion;
  final bool isDownloading;
  final double downloadProgress;

  const CraftApp({
    required this.id,
    required this.packageName,
    required this.name,
    required this.tagLine,
    required this.description,
    required this.version,
    required this.versionCode,
    required this.lastUpdated,
    required this.githubUrl,
    required this.apkDownloadUrl,
    required this.accentColor,
    required this.icon,
    required this.tagPrefix,
    this.status = AppInstallState.notInstalled,
    this.installedVersion,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
  });

  CraftApp copyWith({
    String? id,
    String? packageName,
    String? name,
    String? tagLine,
    String? description,
    String? version,
    int? versionCode,
    String? lastUpdated,
    String? githubUrl,
    String? apkDownloadUrl,
    Color? accentColor,
    String? icon,
    String? tagPrefix,
    AppInstallState? status,
    String? installedVersion,
    bool? isDownloading,
    double? downloadProgress,
  }) {
    return CraftApp(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      name: name ?? this.name,
      tagLine: tagLine ?? this.tagLine,
      description: description ?? this.description,
      version: version ?? this.version,
      versionCode: versionCode ?? this.versionCode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      githubUrl: githubUrl ?? this.githubUrl,
      apkDownloadUrl: apkDownloadUrl ?? this.apkDownloadUrl,
      accentColor: accentColor ?? this.accentColor,
      icon: icon ?? this.icon,
      tagPrefix: tagPrefix ?? this.tagPrefix,
      status: status ?? this.status,
      installedVersion: installedVersion ?? this.installedVersion,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}