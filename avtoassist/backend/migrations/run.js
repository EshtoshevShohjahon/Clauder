const fs = require('fs');
const path = require('path');
const db = require('../config/database');

/**
 * Database migratsiyalarini ishga tushirish.
 * Har bir migratsiya FAQAT BIR MARTA bajariladi (schema_migrations jadvali orqali).
 * Shu sabab serverni qayta ishga tushirganda dublikat ma'lumot bo'lmaydi.
 */
async function runMigrations() {
  try {
    console.log('🔄 Migratsiyalar boshlanmoqda...\n');

    // Bajarilgan migratsiyalarni kuzatuvchi jadval
    await db.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        filename TEXT PRIMARY KEY,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    const migrationsDir = __dirname;
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      const { rows } = await db.query(
        'SELECT 1 FROM schema_migrations WHERE filename = $1',
        [file]
      );

      if (rows.length > 0) {
        console.log(`⏭️  O'tkazib yuborildi (allaqachon bajarilgan): ${file}`);
        continue;
      }

      console.log(`⚙️  Ishga tushirilmoqda: ${file}`);

      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');

      await db.query(sql);
      await db.query(
        'INSERT INTO schema_migrations (filename) VALUES ($1)',
        [file]
      );

      console.log(`✓ Bajarildi: ${file}\n`);
    }

    console.log('✅ Barcha migratsiyalar muvaffaqiyatli bajarildi!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migratsiya xatosi:', error.message);
    console.error(error);
    process.exit(1);
  }
}

runMigrations();
