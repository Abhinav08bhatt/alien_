import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/alien_apps.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final CraftApp app;
  final VoidCallback onAction;

  const AppCard({super.key, required this.app, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: [V0.16.0] ------------- [GITHUB ↗]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                app.version,
                style: TextStyle(
                  fontFamily: AppFonts.digital,
                  color: app.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              InkWell(
                onTap: () => launchUrl(Uri.parse(app.githubUrl)),
                child: const Row(
                  children: [
                    Text(
                      'GITHUB ',
                      style: TextStyle(
                        fontFamily: AppFonts.digital,
                        color: AppColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Icon(Icons.north_east_rounded, size: 12, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // App Profile: [Icon]  [Title  BY ARTCRAFT]
          //                      [Tagline            ]
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: app.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: app.accentColor.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    app.icon,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.apps_rounded,
                        color: app.accentColor,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          app.name,
                          style: const TextStyle(
                            fontFamily: AppFonts.title,
                            fontSize: 19,
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBg,
                            border: Border.all(color: AppColors.badgeText.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            "By alien_",
                            style: TextStyle(
                              fontFamily: AppFonts.digital,
                              fontSize: 9,
                              color: AppColors.badgeText,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      app.tagLine,
                      style: const TextStyle(
                        fontFamily: AppFonts.primary,
                        fontSize: 12.5,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description & Date
          Text(
            app.description,
            style: const TextStyle(
              fontFamily: AppFonts.primary,
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${app.lastUpdated}',
            style: const TextStyle(
              fontFamily: AppFonts.primary,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Available to install badge (if not installed)
          if (app.status == AppInstallState.notInstalled)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight, width: 0.8),
              ),
              child: const Text(
                'AVAILABLE TO INSTALL',
                style: TextStyle(
                  fontFamily: AppFonts.digital,
                  fontSize: 10,
                  color: AppColors.textSub,
                  letterSpacing: 1.1,
                ),
              ),
            ),

          // Button Row: [ ACTION (OPEN/UPDATE/INSTALL) ]  [ ... ]
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: app.status == AppInstallState.updateAvailable
                            ? app.accentColor
                            : AppColors.borderLight,
                        width: 1.2,
                      ),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: app.isDownloading ? null : onAction,
                    child: app.isDownloading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: app.downloadProgress,
                                  color: app.accentColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${(app.downloadProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontFamily: AppFonts.digital,
                                  color: AppColors.textMain,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            switch (app.status) {
                              AppInstallState.upToDate => 'OPEN',
                              AppInstallState.updateAvailable => 'UPDATE TO ${app.version}',
                              AppInstallState.notInstalled => 'INSTALL',
                            },
                            style: TextStyle(
                              fontFamily: AppFonts.digital,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                              color: app.status == AppInstallState.updateAvailable
                                  ? app.accentColor
                                  : AppColors.textMain,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                width: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                ),
                child: const Icon(Icons.more_horiz, color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}