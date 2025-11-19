# 🔐 Setup GitHub Authentication dengan Gmail

Jika Anda login GitHub menggunakan Gmail, ikuti panduan ini untuk setup authentication.

## 📋 Opsi 1: Personal Access Token (Paling Mudah)

### Langkah 1: Buat Personal Access Token

1. Buka GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
   - Atau langsung: https://github.com/settings/tokens

2. Klik **"Generate new token"** → **"Generate new token (classic)"**

3. Beri nama token (contoh: "Warungin Auto-Commit")

4. Pilih scope/permission:
   - ✅ **repo** (Full control of private repositories)
   - ✅ **workflow** (Update GitHub Action workflows) - opsional

5. Klik **"Generate token"**

6. **⚠️ PENTING:** Copy token sekarang! Token hanya ditampilkan sekali.

### Langkah 2: Setup Token di Git

Jalankan perintah berikut di terminal (Git Bash):

```bash
# Simpan token untuk digunakan nanti
git config --global credential.helper store

# Atau untuk Windows, gunakan:
git config --global credential.helper wincred
```

Saat push pertama kali, Git akan meminta:
- **Username**: Gmail Anda (atau username GitHub)
- **Password**: Masukkan **Personal Access Token** (bukan password Gmail!)

## 📋 Opsi 2: SSH Key (Lebih Aman)

### Langkah 1: Generate SSH Key

Jalankan di Git Bash:

```bash
# Ganti dengan email Gmail Anda
ssh-keygen -t ed25519 -C "your-email@gmail.com"

# Tekan Enter untuk menggunakan lokasi default
# Masukkan passphrase (opsional, bisa dikosongkan)
```

### Langkah 2: Copy Public Key

```bash
# Tampilkan public key
cat ~/.ssh/id_ed25519.pub
```

Copy seluruh output (mulai dari `ssh-ed25519` sampai email).

### Langkah 3: Tambahkan ke GitHub

1. Buka GitHub → **Settings** → **SSH and GPG keys**
   - Atau langsung: https://github.com/settings/keys

2. Klik **"New SSH key"**

3. Beri judul (contoh: "Warungin Laptop")

4. Paste public key yang sudah di-copy

5. Klik **"Add SSH key"**

### Langkah 4: Update Remote URL ke SSH

Jika sudah setup remote dengan HTTPS, ubah ke SSH:

```bash
# Cek remote saat ini
git remote -v

# Ubah ke SSH (ganti username dengan username GitHub Anda)
git remote set-url origin git@github.com:username/Warungin.git
```

## 📋 Opsi 3: GitHub CLI (gh)

### Install GitHub CLI

Download dari: https://cli.github.com/

Atau dengan package manager:
```bash
# Windows (dengan Chocolatey)
choco install gh

# Atau download installer dari website
```

### Login dengan GitHub CLI

```bash
# Login
gh auth login

# Pilih:
# - GitHub.com
# - HTTPS
# - Login dengan browser
# - Authorize GitHub CLI
```

Setelah login, Git akan otomatis menggunakan credentials dari GitHub CLI.

## ✅ Verifikasi Setup

Setelah setup, test dengan:

```bash
# Test koneksi
git ls-remote origin

# Atau test push
git push origin main
```

Jika berhasil, berarti authentication sudah benar!

## 🔧 Troubleshooting

### Error: Authentication failed
- Pastikan Personal Access Token sudah benar
- Pastikan token belum expired
- Cek apakah token memiliki permission `repo`

### Error: Permission denied (publickey)
- Pastikan SSH key sudah ditambahkan ke GitHub
- Test koneksi: `ssh -T git@github.com`
- Pastikan remote URL menggunakan SSH (bukan HTTPS)

### Error: Support for password authentication was removed
- GitHub tidak lagi menerima password biasa
- Gunakan Personal Access Token atau SSH Key

## 💡 Rekomendasi

Untuk kemudahan: **Personal Access Token** (Opsi 1)
Untuk keamanan: **SSH Key** (Opsi 2)