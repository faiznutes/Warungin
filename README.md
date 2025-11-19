# Warungin

Repository untuk proyek Warungin dengan auto-commit ke GitHub.

## 🚀 Setup Awal

### 1. Setup GitHub Repository

Jalankan script setup untuk menghubungkan repo dengan GitHub:

```bash
bash setup-github.sh
```

Atau melalui Cursor:
- Tekan `Ctrl+Shift+P` (atau `Cmd+Shift+P` di Mac)
- Ketik "Tasks: Run Task"
- Pilih "Setup GitHub"
- Masukkan URL GitHub repository Anda (contoh: `https://github.com/username/Warungin.git`)

### 2. Inisialisasi Git (jika belum)

Jika belum ada git repository, jalankan:

```bash
git init
git add .
git commit -m "Initial commit"
```

## 📝 Auto-Commit

### Cara 1: Menggunakan Script (Manual)

Setelah selesai edit file, jalankan:

```bash
bash auto-commit.sh
```

Script ini akan:
- ✅ Menambahkan semua perubahan
- ✅ Membuat commit dengan timestamp
- ✅ Push otomatis ke GitHub

### Cara 2: Menggunakan Task di Cursor

1. Tekan `Ctrl+Shift+P` (atau `Cmd+Shift+P` di Mac)
2. Ketik "Tasks: Run Task"
3. Pilih "Auto-Commit & Push"

### Cara 3: Auto-Commit Otomatis (Git Hook)

Git hook sudah di-setup di `.git/hooks/post-commit`. Setelah setiap commit, perubahan akan otomatis di-push ke GitHub.

**Catatan:** Hook ini hanya akan push jika remote GitHub sudah di-setup.

## ⚙️ Konfigurasi

- **Terminal**: Git Bash sudah dikonfigurasi sebagai default terminal
- **Auto-commit**: Script tersedia di `auto-commit.sh`
- **Git Hook**: Auto-push setelah commit di `.git/hooks/post-commit`

## 📋 Perintah Git Berguna

```bash
# Cek status
git status

# Lihat perubahan
git diff

# Lihat history commit
git log --oneline

# Pull perubahan terbaru dari GitHub
git pull origin main
```

## 🔐 Setup Authentication GitHub

Jika Anda login GitHub menggunakan **Gmail**, Anda perlu setup authentication terlebih dahulu.

### Quick Setup

Jalankan script setup authentication:

```bash
bash setup-auth.sh
```

Atau ikuti panduan lengkap di file `setup-github-auth.md`.

### Opsi Authentication:

1. **Personal Access Token** (Paling Mudah) - Rekomendasi untuk pemula
2. **SSH Key** (Lebih Aman) - Rekomendasi untuk keamanan
3. **GitHub CLI** - Otomatis handle authentication

**Catatan Penting:**
- GitHub tidak lagi menerima password biasa
- Gunakan Personal Access Token atau SSH Key
- Token hanya ditampilkan sekali saat dibuat, simpan dengan aman!

## 🔧 Troubleshooting

### Git tidak terdeteksi
Pastikan Git sudah terinstall dan ada di PATH. Cek dengan:
```bash
git --version
```

### Remote belum di-setup
Jalankan `bash setup-github.sh` untuk setup remote GitHub.

### Push gagal - Authentication failed
- Pastikan sudah setup authentication (jalankan `bash setup-auth.sh`)
- Jika menggunakan Token, pastikan token belum expired
- Jika menggunakan SSH, pastikan SSH key sudah ditambahkan ke GitHub
- Lihat panduan lengkap di `setup-github-auth.md`

### Error: Support for password authentication was removed
GitHub tidak lagi menerima password. Setup Personal Access Token atau SSH Key dengan menjalankan:
```bash
bash setup-auth.sh
```
