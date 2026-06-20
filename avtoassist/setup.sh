#!/bin/bash

# AvtoAssist - Avtomatik Setup Script
# Barcha narsani avtomatik o'rnatadi va ishga tushiradi

set -e  # Xatolik bo'lsa to'xtaydi

echo "🚀 AvtoAssist - Avtomatik Setup Boshlanmoqda..."
echo "================================================"
echo ""

# Ranglar
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Step 1: Check prerequisites
echo "📋 Qadam 1: Dasturlar tekshirilmoqda..."
echo "----------------------------------------"

MISSING_TOOLS=()

if ! command_exists node; then
    MISSING_TOOLS+=("Node.js")
    print_error "Node.js o'rnatilmagan"
else
    NODE_VERSION=$(node -v)
    print_success "Node.js topildi: $NODE_VERSION"
fi

if ! command_exists psql; then
    MISSING_TOOLS+=("PostgreSQL")
    print_error "PostgreSQL o'rnatilmagan"
else
    PSQL_VERSION=$(psql --version | awk '{print $3}')
    print_success "PostgreSQL topildi: $PSQL_VERSION"
fi

if ! command_exists flutter; then
    MISSING_TOOLS+=("Flutter")
    print_warning "Flutter o'rnatilmagan (mobile uchun kerak)"
else
    FLUTTER_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
    print_success "Flutter topildi: $FLUTTER_VERSION"
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo ""
    print_error "Quyidagi dasturlar o'rnatilmagan:"
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "O'rnatish yo'riqnomasi:"
    echo "  Node.js: https://nodejs.org"
    echo "  PostgreSQL: https://www.postgresql.org/download/"
    echo "  Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo ""

# Step 2: PostgreSQL Database Setup
echo "🗄️  Qadam 2: PostgreSQL Database yaratilmoqda..."
echo "------------------------------------------------"

read -p "PostgreSQL superuser nomi (default: postgres): " DB_SUPERUSER
DB_SUPERUSER=${DB_SUPERUSER:-postgres}

read -sp "PostgreSQL parol: " DB_PASSWORD
echo ""

if [ -z "$DB_PASSWORD" ]; then
    print_error "Parol kiritilmadi!"
    exit 1
fi

# Test connection
print_info "Database connection tekshirilmoqda..."
export PGPASSWORD=$DB_PASSWORD

if psql -U $DB_SUPERUSER -h localhost -c "SELECT 1" >/dev/null 2>&1; then
    print_success "PostgreSQL'ga ulanish muvaffaqiyatli"
else
    print_error "PostgreSQL'ga ulanib bo'lmadi. Parol yoki foydalanuvchi nomi noto'g'ri."
    exit 1
fi

# Create database
print_info "Database yaratilmoqda..."
psql -U $DB_SUPERUSER -h localhost <<EOF
-- Drop if exists (faqat test uchun)
DROP DATABASE IF EXISTS avtoassist;

-- Create database
CREATE DATABASE avtoassist;
EOF

if [ $? -eq 0 ]; then
    print_success "Database 'avtoassist' yaratildi"
else
    print_error "Database yaratishda xatolik"
    exit 1
fi

# Add PostGIS extension
print_info "PostGIS extension qo'shilmoqda..."
psql -U $DB_SUPERUSER -h localhost -d avtoassist <<EOF
CREATE EXTENSION IF NOT EXISTS postgis;
EOF

if [ $? -eq 0 ]; then
    print_success "PostGIS extension qo'shildi"
else
    print_warning "PostGIS extension qo'shilmadi (muhim emas)"
fi

unset PGPASSWORD
echo ""

# Step 3: Backend Setup
echo "⚙️  Qadam 3: Backend sozlanmoqda..."
echo "-----------------------------------"

cd backend

# Install dependencies
print_info "Node.js paketlari o'rnatilmoqda..."
npm install --silent

if [ $? -eq 0 ]; then
    print_success "Paketlar o'rnatildi"
else
    print_error "npm install xatosi"
    exit 1
fi

# Create .env file
print_info ".env fayli yaratilmoqda..."
cat > .env <<EOF
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=avtoassist
DB_USER=$DB_SUPERUSER
DB_PASSWORD=$DB_PASSWORD

JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d
EOF

print_success ".env fayli yaratildi"

# Run migrations
print_info "Database migration bajarilmoqda..."
npm run migrate

if [ $? -eq 0 ]; then
    print_success "Migration bajarildi (demo ma'lumotlar qo'shildi)"
else
    print_error "Migration xatosi"
    exit 1
fi

cd ..
echo ""

# Step 4: Flutter Setup
echo "📱 Qadam 4: Flutter sozlanmoqda..."
echo "----------------------------------"

if command_exists flutter; then
    cd mobile
    
    print_info "Flutter paketlari o'rnatilmoqda..."
    flutter pub get >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Flutter paketlari o'rnatildi"
    else
        print_error "flutter pub get xatosi"
        exit 1
    fi
    
    cd ..
else
    print_warning "Flutter o'rnatilmagan - mobile qism o'tkazib yuborildi"
fi

echo ""
echo "================================================"
echo "🎉 Setup muvaffaqiyatli yakunlandi!"
echo "================================================"
echo ""
echo "📊 Yaratilgan resurslar:"
echo "  - Database: avtoassist"
echo "  - Backend: http://localhost:3000"
echo "  - Demo users:"
echo "      +998901234567 / password123 (Client)"
echo "      +998902345678 / password123 (Provider)"
echo ""
echo "🚀 Keyingi qadamlar:"
echo ""
echo "1. Backend serverni ishga tushirish:"
echo "   cd backend && npm run dev"
echo ""

if command_exists flutter; then
    echo "2. Flutter ilovani ishga tushirish (yangi terminal):"
    echo "   cd mobile && flutter run"
    echo ""
fi

echo "Yoki avtomatik ishga tushirish uchun:"
echo "   ./start.sh"
echo ""
print_success "Omad!"
