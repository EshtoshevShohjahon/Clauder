#!/bin/bash

# AvtoAssist - Avtomatik Ishga Tushirish
# Backend va Flutter ilovani bir vaqtning o'zida ishga tushiradi

set -e

echo "🚀 AvtoAssist ishga tushirilmoqda..."
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Check if backend is set up
if [ ! -f "backend/.env" ]; then
    echo "❌ Backend sozlanmagan!"
    echo "Avval setup.sh ni ishga tushiring:"
    echo "   ./setup.sh"
    exit 1
fi

# Check if backend dependencies are installed
if [ ! -d "backend/node_modules" ]; then
    echo "❌ Backend dependencies o'rnatilmagan!"
    echo "   cd backend && npm install"
    exit 1
fi

# Function to kill processes on exit
cleanup() {
    echo ""
    echo "Jarayonlar to'xtatilmoqda..."
    kill $BACKEND_PID 2>/dev/null
    kill $FLUTTER_PID 2>/dev/null
    exit
}

trap cleanup EXIT INT TERM

# Start Backend
print_info "Backend server ishga tushirilmoqda..."
cd backend
npm run dev > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 3

# Check if backend is running
if kill -0 $BACKEND_PID 2>/dev/null; then
    print_success "Backend server ishga tushdi (PID: $BACKEND_PID)"
    print_info "Backend logs: tail -f backend.log"
    print_info "Backend URL: http://localhost:3000"
else
    echo "❌ Backend ishga tushmadi!"
    echo "Loglarni ko'rish: cat backend.log"
    exit 1
fi

echo ""

# Start Flutter (if available)
if command -v flutter >/dev/null 2>&1; then
    print_info "Flutter emulator tekshirilmoqda..."
    
    # Check for running emulators/devices
    DEVICES=$(flutter devices 2>/dev/null | grep -E "chrome|emulator|simulator" | head -n 1)
    
    if [ -z "$DEVICES" ]; then
        print_warning "Hech qanday qurilma topilmadi!"
        echo ""
        echo "Android emulator ishga tushirish:"
        echo "  flutter emulators"
        echo "  flutter emulators --launch <emulator_id>"
        echo ""
        echo "Yoki Chrome'da ishga tushirish:"
        echo "  cd mobile && flutter run -d chrome"
        echo ""
        echo "Backend server ishlayapti. Mobile ilovani qo'lda ishga tushiring."
    else
        print_success "Qurilma topildi"
        print_info "Flutter ilova ishga tushirilmoqda..."
        
        cd mobile
        flutter run > ../flutter.log 2>&1 &
        FLUTTER_PID=$!
        cd ..
        
        sleep 5
        
        if kill -0 $FLUTTER_PID 2>/dev/null; then
            print_success "Flutter ilova ishga tushdi (PID: $FLUTTER_PID)"
            print_info "Flutter logs: tail -f flutter.log"
        else
            print_warning "Flutter ilova ishga tushmadi"
            echo "Loglarni ko'rish: cat flutter.log"
        fi
    fi
else
    print_warning "Flutter o'rnatilmagan - faqat backend ishlayapti"
fi

echo ""
echo "===================================="
echo "✅ AvtoAssist ishga tushdi!"
echo "===================================="
echo ""
echo "📊 Servislar:"
echo "  Backend:  http://localhost:3000"
echo "  Health:   http://localhost:3000/health"
if command -v flutter >/dev/null 2>&1 && [ ! -z "$FLUTTER_PID" ]; then
    echo "  Mobile:   Emulator/Simulator"
fi
echo ""
echo "🔑 Test userlar:"
echo "  Client:   +998901234567 / password123"
echo "  Provider: +998902345678 / password123"
echo ""
echo "📝 Loglar:"
echo "  Backend:  tail -f backend.log"
if command -v flutter >/dev/null 2>&1 && [ ! -z "$FLUTTER_PID" ]; then
    echo "  Flutter:  tail -f flutter.log"
fi
echo ""
echo "⏹️  To'xtatish: Ctrl+C"
echo ""

# Keep running
print_info "Jarayonlar ishlayapti..."
wait
