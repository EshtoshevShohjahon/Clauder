const fs = require('fs');
const path = require('path');
const db = require('../config/database');

/**
 * Database migratsiyalarini ishga tushirish
 */
async function runMigrations() {
  try {
    console.log('🔄 Migratsiyalar boshlanmoqda...\n');

    const migrationsDir = __dirname;
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      console.log(`⚙️  Ishga tushirilmoqda: ${file}`);
      
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      await db.query(sql);
      
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
