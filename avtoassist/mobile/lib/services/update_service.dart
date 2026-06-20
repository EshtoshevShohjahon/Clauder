import 'package:avtoassist/services/api_service.dart';
import 'package:avtoassist/utils/constants.dart';

/// Yangilanish ma'lumoti
class UpdateInfo {
  final String version;
  final String apkUrl;
  final String changelog;
  final bool force;

  UpdateInfo({
    required this.version,
    required this.apkUrl,
    required this.changelog,
    required this.force,
  });
}

/// In-app updater - backend'dan eng yangi versiyani tekshiradi
class UpdateService {
  final ApiService _api = ApiService();

  /// Yangilanish bormi? (build raqami solishtiriladi)
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final res = await _api.get('/version');
      if (res['success'] == true) {
        final d = res['data'] as Map<String, dynamic>;
        final latestBuild = (d['latest_build'] as num?)?.toInt() ?? 0;
        final apkUrl = (d['apk_url'] as String?) ?? '';

        if (latestBuild > AppConstants.appVersionCode && apkUrl.isNotEmpty) {
          return UpdateInfo(
            version: (d['latest_version'] as String?) ?? '',
            apkUrl: apkUrl,
            changelog: (d['changelog'] as String?) ?? '',
            force: d['force'] == true,
          );
        }
      }
    } catch (_) {
      // Tarmoq xatosi - jim o'tkazib yuboramiz
    }
    return null;
  }
}
