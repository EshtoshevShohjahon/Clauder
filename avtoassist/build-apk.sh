#!/bin/bash

# AvtoAssist - Android APK Build Script
# Release APK yaratadi va signing qiladi

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "📱 AvtoAssist - Android APK Build"
echo "=================================="
echo ""

# Check Flutter
if ! command -v flutter >/dev/null 2>&1; then
    print_error "Flutter o'rnatilmagan!"
    exit 1
fi

cd mobile

# Clean previous builds
print_info "Oldingi buildlarni tozalash..."
flutter clean
print_success "Tozalandi"
echo ""

# Get dependencies
print_info "Dependencies yuklanmoqda..."
flutter pub get
print_success "Dependencies yuklandi"
echo ""

# Build APK
print_info "Release APK build qilinmoqda..."
print_warning "Bu 5-10 daqiqa davom etishi mumkin..."
echo ""

flutter build apk --release

if [ $? -eq 0 ]; then
    print_success "APK muvaffaqiyatli yaratildi!"
    echo ""
    echo "📦 APK joylashuvi:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    print_info "APK hajmi: $APK_SIZE"
    echo ""
    
    # Copy to easy location
    cp build/app/outputs/flutter-apk/app-release.apk ../avtoassist-release.apk
    print_success "APK avtoassist/ papkaga ko'chirildi"
    echo ""
    
    echo "🎉 Tayyor!"
    echo ""
    echo "📲 O'rnatish:"
    echo "  1. APK ni telefoniga yuborish (USB, Telegram, Email...)"
    echo "  2. Telefonida faylni ochish"
    echo "  3. 'Install' ni bosish"
    echo ""
    echo "⚠️  Eslatma:"
    echo "  - 'Unknown sources' dan o'rnatishga ruxsat berish kerak"
    echo "  - Bu unsigned APK (faqat test uchun)"
    echo "  - Play Store uchun signed AAB kerak"
else
    print_error "APK build qilishda xatolik!"
    exit 1
fi

cd ..
