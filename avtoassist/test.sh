#!/bin/bash

# AvtoAssist - API Test Script
# Backend API'ni to'liq test qiladi

set -e

BASE_URL="http://localhost:3000"
TOKEN=""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}🧪 TEST: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ PASS: $1${NC}"
}

print_fail() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    exit 1
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

echo "🧪 AvtoAssist API Test"
echo "====================="
echo ""

# Test 1: Health Check
print_test "Health Check"
RESPONSE=$(curl -s $BASE_URL/health)
if echo $RESPONSE | grep -q "success"; then
    print_pass "Server ishlayapti"
else
    print_fail "Server javob bermadi"
fi
echo ""

# Test 2: Register new user
print_test "Ro'yxatdan o'tish (yangi user)"
PHONE="+99890999$(date +%s | tail -c 5)"
RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"$PHONE\",\"password\":\"test123\",\"full_name\":\"Test User\"}")

if echo $RESPONSE | grep -q "success"; then
    print_pass "Ro'yxatdan o'tish muvaffaqiyatli"
    TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    print_info "Token olindi"
else
    print_fail "Ro'yxatdan o'tishda xatolik"
fi
echo ""

# Test 3: Login with demo user
print_test "Kirish (demo user bilan)"
RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"phone":"+998901234567","password":"password123"}')

if echo $RESPONSE | grep -q "success"; then
    print_pass "Kirish muvaffaqiyatli"
    TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    print_info "Demo user token: ${TOKEN:0:20}..."
else
    print_fail "Kirishda xatolik"
fi
echo ""

# Test 4: Get user profile
print_test "Profil olish"
RESPONSE=$(curl -s $BASE_URL/api/users/me \
    -H "Authorization: Bearer $TOKEN")

if echo $RESPONSE | grep -q "phone"; then
    print_pass "Profil olindi"
    USER_ID=$(echo $RESPONSE | grep -o '"id":[0-9]*' | cut -d':' -f2 | head -1)
    print_info "User ID: $USER_ID"
else
    print_fail "Profil olinmadi"
fi
echo ""

# Test 5: Get orders
print_test "So'rovlar ro'yxati"
RESPONSE=$(curl -s $BASE_URL/api/orders \
    -H "Authorization: Bearer $TOKEN")

if echo $RESPONSE | grep -q "orders"; then
    ORDER_COUNT=$(echo $RESPONSE | grep -o '"id":[0-9]*' | wc -l)
    print_pass "So'rovlar olindi ($ORDER_COUNT ta)"
else
    print_fail "So'rovlar olinmadi"
fi
echo ""

# Test 6: Get providers
print_test "Providerlar ro'yxati"
RESPONSE=$(curl -s $BASE_URL/api/providers)

if echo $RESPONSE | grep -q "providers"; then
    PROVIDER_COUNT=$(echo $RESPONSE | grep -o '"id":[0-9]*' | wc -l)
    print_pass "Providerlar olindi ($PROVIDER_COUNT ta)"
else
    print_fail "Providerlar olinmadi"
fi
echo ""

# Test 7: Get vehicles
print_test "Avtomobillar ro'yxati"
RESPONSE=$(curl -s $BASE_URL/api/vehicles \
    -H "Authorization: Bearer $TOKEN")

if echo $RESPONSE | grep -q "vehicles"; then
    print_pass "Avtomobillar ro'yxati olindi"
else
    print_fail "Avtomobillar olinmadi"
fi
echo ""

# Test 8: Create vehicle
print_test "Avtomobil qo'shish"
RESPONSE=$(curl -s -X POST $BASE_URL/api/vehicles \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"brand":"Chevrolet","model":"Gentra","year":2020,"current_mileage":45000}')

if echo $RESPONSE | grep -q "success"; then
    print_pass "Avtomobil qo'shildi"
    VEHICLE_ID=$(echo $RESPONSE | grep -o '"id":[0-9]*' | cut -d':' -f2)
    print_info "Vehicle ID: $VEHICLE_ID"
else
    print_fail "Avtomobil qo'shilmadi"
fi
echo ""

# Test 9: Add oil change
if [ ! -z "$VEHICLE_ID" ]; then
    print_test "Moy almashtirish qo'shish"
    RESPONSE=$(curl -s -X POST $BASE_URL/api/vehicles/$VEHICLE_ID/oil-changes \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"oil_type\":\"10W-40\",\"oil_brand\":\"Shell\",\"mileage\":45000,\"next_change_mileage\":55000,\"price\":250000,\"changed_at\":\"$(date +%Y-%m-%d)\"}")
    
    if echo $RESPONSE | grep -q "success"; then
        print_pass "Moy almashtirish qo'shildi"
    else
        print_fail "Moy almashtirish qo'shilmadi"
    fi
    echo ""
fi

# Test 10: Get oil changes
if [ ! -z "$VEHICLE_ID" ]; then
    print_test "Moy almashtirish tarixi"
    RESPONSE=$(curl -s $BASE_URL/api/vehicles/$VEHICLE_ID/oil-changes \
        -H "Authorization: Bearer $TOKEN")
    
    if echo $RESPONSE | grep -q "oil_changes"; then
        print_pass "Moy almashtirish tarixi olindi"
    else
        print_fail "Tarix olinmadi"
    fi
    echo ""
fi

echo "======================================"
echo "✅ Barcha testlar muvaffaqiyatli o'tdi!"
echo "======================================"
echo ""
echo "📊 Test natijasi:"
echo "  Serverning holatini tekshirdik"
echo "  Ro'yxatdan o'tdik"
echo "  Kirdik (login)"
echo "  Profil oldik"
echo "  So'rovlar ro'yxatini ko'rdik"
echo "  Providerlarni ko'rdik"
echo "  Avtomobil qo'shdik"
echo "  Moy almashtirish qo'shdik"
echo ""
print_pass "Backend to'liq ishlamoqda!"
