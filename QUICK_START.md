# 🚀 Quick Start - Push Project ke GitHub

Panduan lengkap untuk push project Warungin dari folder lokal ke GitHub dan deploy di VPS.

## 📋 Langkah 1: Copy File Project

File Docker dan konfigurasi sudah ada di folder GitHub ini. Sekarang kita perlu copy source code dari project asli.

### Opsi A: Menggunakan Script (Otomatis)

```bash
# Di folder GitHub (F:\Backup W11\Github\Warungin)
bash copy-project-files.sh
```

Script ini akan otomatis copy:
- ✅ Backend source code (`src/`)
- ✅ Frontend source code (`client/`)
- ✅ Database schema (`prisma/`)
- ✅ Scripts penting
- ✅ Nginx configuration
- ✅ Package files

### Opsi B: Manual Copy

Jika script tidak bekerja, copy manual:

```bash
# Dari folder project asli (F:\Backup W11\Warungin)
# Copy ke folder GitHub (F:\Backup W11\Github\Warungin)

# Copy backend
cp -r "F:/Backup W11/Warungin/src" "F:/Backup W11/Github/Warungin/"

# Copy frontend (exclude node_modules dan dist)
rsync -av --exclude 'node_modules' --exclude 'dist' --exclude '.vite' \
    "F:/Backup W11/Warungin/client/" "F:/Backup W11/Github/Warungin/client/"

# Copy database
cp -r "F:/Backup W11/Warungin/prisma" "F:/Backup W11/Github/Warungin/"

# Copy scripts penting
mkdir -p "F:/Backup W11/Github/Warungin/scripts"
cp "F:/Backup W11/Warungin/scripts/docker-startup.sh" "F:/Backup W11/Github/Warungin/scripts/"
cp "F:/Backup W11/Warungin/scripts/create-super-admin-docker.js" "F:/Backup W11/Github/Warungin/scripts/"

# Copy nginx config
mkdir -p "F:/Backup W11/Github/Warungin/nginx/conf.d"
cp "F:/Backup W11/Warungin/nginx/conf.d/default.conf" "F:/Backup W11/Github/Warungin/nginx/conf.d/"
cp "F:/Backup W11/Warungin/nginx/nginx.conf" "F:/Backup W11/Github/Warungin/nginx/"

# Copy package files
cp "F:/Backup W11/Warungin/package.json" "F:/Backup W11/Github/Warungin/"
cp "F:/Backup W11/Warungin/package-lock.json" "F:/Backup W11/Github/Warungin/"
cp "F:/Backup W11/Warungin/tsconfig.json" "F:/Backup W11/Github/Warungin/"

# Copy client package files
cp "F:/Backup W11/Warungin/client/package.json" "F:/Backup W11/Github/Warungin/client/"
cp "F:/Backup W11/Warungin/client/nginx.conf" "F:/Backup W11/Github/Warungin/client/"
```

## 📋 Langkah 2: Setup GitHub Repository

### 2.1 Buat Repository di GitHub

1. Buka https://github.com
2. Klik "New repository"
3. Nama: `Warungin`
4. Description: `Multi-Tenant POS System`
5. Pilih Public atau Private
6. Jangan centang "Initialize with README"
7. Klik "Create repository"

### 2.2 Setup Remote dan Push

```bash
# Di folder GitHub
bash setup-github-repo.sh
```

Atau manual:

```bash
# Initialize git (jika belum)
git init

# Add remote
git remote add origin https://github.com/username/Warungin.git

# Add files
git add .

# Commit
git commit -m "Initial commit: Warungin POS System with Docker"

# Push
git push -u origin main
```

### 2.3 Setup Authentication

Jika push gagal karena authentication:

```bash
bash setup-auth.sh
```

Pilih opsi 1 (Personal Access Token) dan ikuti instruksi.

## 📋 Langkah 3: Deploy di VPS

### 3.1 SSH ke VPS

```bash
ssh user@your-vps-ip
```

### 3.2 Install Docker (jika belum)

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### 3.3 Clone Repository

```bash
git clone https://github.com/username/Warungin.git
cd Warungin
```

### 3.4 Setup Environment

```bash
# Copy env.example ke .env
cp env.example .env

# Edit .env dengan nano atau vim
nano .env
```

**Penting:** Edit variabel berikut:
- `POSTGRES_PASSWORD` - Password database yang kuat
- `JWT_SECRET` - Random string minimal 32 karakter
- `JWT_REFRESH_SECRET` - Random string minimal 32 karakter
- `FRONTEND_URL` - URL domain Anda
- `BACKEND_URL` - URL backend API
- `CORS_ORIGIN` - URL yang diizinkan
- Konfigurasi SMTP dan Midtrans

### 3.5 Deploy

```bash
# Menggunakan script deployment
bash deploy-vps.sh

# Atau manual
docker compose up -d --build

# Lihat logs
docker compose logs -f
```

### 3.6 Cek Status

```bash
# Status containers
docker compose ps

# Health check
curl http://localhost/api/health

# Frontend
curl http://localhost
```

## 📋 Langkah 4: Setup Domain & SSL (Opsional)

### 4.1 Setup DNS

Point domain ke IP VPS:
- A Record: `@` → IP VPS
- A Record: `www` → IP VPS

### 4.2 Setup SSL dengan Let's Encrypt

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal
sudo certbot renew --dry-run
```

### 4.3 Update Nginx Config

Edit `nginx/conf.d/default.conf` untuk menambahkan SSL configuration.

## ✅ Checklist Deployment

- [ ] File project sudah di-copy ke folder GitHub
- [ ] Repository GitHub sudah dibuat
- [ ] File sudah di-push ke GitHub
- [ ] VPS sudah siap (Docker terinstall)
- [ ] Repository sudah di-clone di VPS
- [ ] File `.env` sudah dikonfigurasi
- [ ] Docker containers sudah running
- [ ] Health check berhasil
- [ ] Domain sudah di-setup (opsional)
- [ ] SSL certificate sudah di-setup (opsional)
- [ ] Super admin password sudah diganti

## 🔄 Update Project

Setelah ada perubahan di local:

```bash
# Di folder lokal (F:\Backup W11\Github\Warungin)

# Copy file baru (jika ada)
bash copy-project-files.sh

# Commit dan push
git add .
git commit -m "Update: description perubahan"
git push origin main

# Di VPS, pull dan rebuild
ssh user@vps-ip
cd Warungin
git pull origin main
docker compose up -d --build
```

## 🆘 Troubleshooting

### Push ke GitHub gagal
- Pastikan authentication sudah di-setup: `bash setup-auth.sh`
- Cek apakah repository sudah dibuat di GitHub
- Pastikan URL remote benar: `git remote -v`

### Copy file gagal
- Pastikan path folder benar
- Gunakan manual copy jika script tidak bekerja
- Pastikan file/folder tidak sedang digunakan

### Deploy di VPS gagal
- Cek logs: `docker compose logs -f`
- Pastikan `.env` sudah dikonfigurasi dengan benar
- Pastikan port 80 dan 443 tidak digunakan aplikasi lain
- Cek firewall: `sudo ufw status`

### Database connection error
- Pastikan `DATABASE_URL` di `.env` benar
- Pastikan postgres container running: `docker compose ps`
- Cek network: `docker network ls`

## 📚 Dokumentasi Lengkap

- [README.md](./README.md) - Dokumentasi lengkap
- [env.example](./env.example) - Contoh environment variables
- [docker-compose.yml](./docker-compose.yml) - Docker configuration

---

**Selamat! Project Warungin siap di-deploy! 🎉**

