#!/bin/bash
# =============================================================================
# Setup Script untuk Silsilah - Aplikasi Silsilah Keluarga
# =============================================================================
# Sebelum menjalankan script ini, pastikan file memiliki permission executable:
#   chmod +x setup.sh
# Kemudian jalankan dengan:
#   ./setup.sh
# =============================================================================

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fungsi helper untuk output
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo ""
echo "============================================="
echo "  Silsilah - Local Development Setup (Mac)"
echo "============================================="
echo ""

# -----------------------------------------------------------------------------
# Step 1: Check PHP
# -----------------------------------------------------------------------------
print_info "Mengecek instalasi PHP..."

if ! command -v php &> /dev/null; then
    print_error "PHP belum terinstall!"
    echo ""
    echo "Install PHP menggunakan Homebrew:"
    echo "  brew install php"
    echo ""
    echo "Jika Homebrew belum terinstall:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    exit 1
fi

PHP_VERSION=$(php -v | head -n 1)
print_success "PHP ditemukan: $PHP_VERSION"

# -----------------------------------------------------------------------------
# Step 2: Check Composer
# -----------------------------------------------------------------------------
print_info "Mengecek instalasi Composer..."

if ! command -v composer &> /dev/null; then
    print_error "Composer belum terinstall!"
    echo ""
    echo "Install Composer menggunakan Homebrew:"
    echo "  brew install composer"
    echo ""
    echo "Atau install secara manual:"
    echo "  curl -sS https://getcomposer.org/installer | php"
    echo "  sudo mv composer.phar /usr/local/bin/composer"
    echo ""
    exit 1
fi

COMPOSER_VERSION=$(composer --version 2>/dev/null)
print_success "Composer ditemukan: $COMPOSER_VERSION"

# -----------------------------------------------------------------------------
# Step 3: Composer Install
# -----------------------------------------------------------------------------
print_info "Menjalankan composer install..."

if ! composer install; then
    print_error "composer install gagal!"
    echo "Periksa error di atas dan coba lagi."
    exit 1
fi

print_success "Dependensi PHP berhasil diinstall."

# -----------------------------------------------------------------------------
# Step 4: Copy .env.example ke .env
# -----------------------------------------------------------------------------
print_info "Mengecek file .env..."

if [ -f .env ]; then
    print_warning "File .env sudah ada, melewati langkah copy."
else
    if ! cp .env.example .env; then
        print_error "Gagal meng-copy .env.example ke .env!"
        exit 1
    fi
    print_success "File .env berhasil dibuat dari .env.example."
fi

# -----------------------------------------------------------------------------
# Step 5: Generate Application Key
# -----------------------------------------------------------------------------
print_info "Mengenerate application key..."

if ! php artisan key:generate; then
    print_error "Gagal mengenerate application key!"
    exit 1
fi

print_success "Application key berhasil digenerate."

# -----------------------------------------------------------------------------
# Step 6: Buat file database SQLite
# -----------------------------------------------------------------------------
print_info "Mengecek file database SQLite..."

if [ -f database/database.sqlite ]; then
    print_warning "File database/database.sqlite sudah ada."
else
    if ! touch database/database.sqlite; then
        print_error "Gagal membuat file database/database.sqlite!"
        exit 1
    fi
    print_success "File database/database.sqlite berhasil dibuat."
fi

# -----------------------------------------------------------------------------
# Step 7: Konfigurasi .env untuk SQLite
# -----------------------------------------------------------------------------
print_info "Mengkonfigurasi .env untuk menggunakan SQLite..."

# Ubah DB_CONNECTION menjadi sqlite
if grep -q "^DB_CONNECTION=" .env; then
    sed -i '' 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
else
    echo "DB_CONNECTION=sqlite" >> .env
fi

# Comment out DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD
sed -i '' 's/^DB_HOST=/#DB_HOST=/' .env
sed -i '' 's/^DB_PORT=/#DB_PORT=/' .env
sed -i '' 's/^DB_DATABASE=/#DB_DATABASE=/' .env
sed -i '' 's/^DB_USERNAME=/#DB_USERNAME=/' .env
sed -i '' 's/^DB_PASSWORD=/#DB_PASSWORD=/' .env

print_success "Konfigurasi .env berhasil diubah ke SQLite."

# -----------------------------------------------------------------------------
# Step 8: Jalankan migrasi database
# -----------------------------------------------------------------------------
print_info "Menjalankan migrasi database..."

if ! php artisan migrate --force; then
    print_error "Migrasi database gagal!"
    echo "Periksa error di atas dan pastikan konfigurasi database sudah benar."
    exit 1
fi

print_success "Migrasi database berhasil dijalankan."

# -----------------------------------------------------------------------------
# Step 9: Jalankan development server
# -----------------------------------------------------------------------------
echo ""
echo "============================================="
print_success "Setup selesai! Menjalankan development server..."
echo "============================================="
echo ""
print_info "Buka http://localhost:8000 di browser"
echo ""

php artisan serve
