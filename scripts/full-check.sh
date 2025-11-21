#!/bin/bash

# Full Check Script for Warungin POS System
# Checks TypeScript, Linting, Prisma, and Tests

set -e  # Exit on error

echo "🔍 Starting Full Check for Warungin POS System..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print info
print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# 1. Prisma Validation
echo "1️⃣  Validating Prisma Schema..."
if npx prisma validate > /dev/null 2>&1; then
    print_success "Prisma Schema OK"
else
    print_error "Prisma schema errors found!"
    npx prisma validate
    exit 1
fi

# 2. Prisma Generate
echo ""
echo "2️⃣  Generating Prisma Client..."
if npm run prisma:generate > /dev/null 2>&1; then
    print_success "Prisma Client Generated"
else
    print_error "Prisma generate errors found!"
    npm run prisma:generate
    exit 1
fi

# 3. Backend TypeScript Check
echo ""
echo "3️⃣  Checking Backend TypeScript..."
if npx tsc --noEmit > /dev/null 2>&1; then
    print_success "Backend TypeScript OK"
else
    print_error "Backend TypeScript errors found!"
    npx tsc --noEmit
    exit 1
fi

# 4. Frontend TypeScript Check
echo ""
echo "4️⃣  Checking Frontend TypeScript..."
cd client
if npx vue-tsc --noEmit > /dev/null 2>&1; then
    print_success "Frontend TypeScript OK"
    cd ..
else
    cd ..
    print_error "Frontend TypeScript errors found!"
    cd client
    npx vue-tsc --noEmit
    cd ..
    exit 1
fi

# 5. Backend Linting
echo ""
echo "5️⃣  Checking Backend Linting..."
if npm run lint > /dev/null 2>&1; then
    print_success "Backend Linting OK"
else
    print_error "Backend linting errors found!"
    npm run lint
    exit 1
fi

# 6. Frontend Linting
echo ""
echo "6️⃣  Checking Frontend Linting..."
cd client
if npm run lint > /dev/null 2>&1; then
    print_success "Frontend Linting OK"
    cd ..
else
    cd ..
    print_error "Frontend linting errors found!"
    cd client
    npm run lint
    cd ..
    exit 1
fi

# 7. Tests (optional - can be skipped with --skip-tests)
if [[ "$1" != "--skip-tests" ]]; then
    echo ""
    echo "7️⃣  Running Tests..."
    if npm test -- --run > /dev/null 2>&1; then
        print_success "Tests OK"
    else
        print_error "Tests failed!"
        npm test -- --run
        exit 1
    fi
else
    print_info "Skipping tests (use --skip-tests to skip)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 All checks passed! ✅${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

