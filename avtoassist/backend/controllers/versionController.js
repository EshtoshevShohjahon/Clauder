/**
 * Ilova versiyasi - in-app updater uchun
 * GET /api/version
 *
 * Qiymatlar .env (Render Environment) dan o'qiladi:
 *   APP_LATEST_VERSION  - ko'rinadigan versiya (masalan 1.1.0)
 *   APP_LATEST_BUILD    - build raqami (butun son, masalan 2)
 *   APP_APK_URL         - yangi APK yuklab olish manzili
 *   APP_CHANGELOG       - o'zgarishlar matni
 *   APP_FORCE_UPDATE    - 'true' bo'lsa majburiy yangilash
 */
function getVersion(req, res) {
  res.json({
    success: true,
    data: {
      latest_version: process.env.APP_LATEST_VERSION || '1.0.0',
      latest_build: parseInt(process.env.APP_LATEST_BUILD || '1', 10),
      apk_url: process.env.APP_APK_URL || '',
      changelog: process.env.APP_CHANGELOG || '',
      force: process.env.APP_FORCE_UPDATE === 'true',
    },
  });
}

module.exports = { getVersion };
