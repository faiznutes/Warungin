# 🔧 Cloudflare Tunnel Troubleshooting

Panduan lengkap untuk mengatasi masalah Cloudflare Tunnel, khususnya Error 1033.

## ❌ Error 1033: Connection Terminated

**Error Message:**
```
Error 1033 Ray ID: xxxxx • 2025-11-19 20:11:12 UTC
Cloudflare Tunnel error
```

**Penyebab:**
- Cloudflare Tunnel tidak bisa connect ke origin (nginx)
- Origin service (nginx) belum ready
- Port atau hostname salah
- Network configuration tidak benar
- Tunnel token tidak valid atau expired

## 🔍 Diagnosis

### 1. Check Cloudflare Tunnel Status

```bash
# Di server
docker compose logs cloudflared
```

Cari error messages seperti:
- `Unable to reach the origin service`
- `Connection refused`
- `Tunnel token invalid`

### 2. Check Nginx Status

```bash
# Pastikan nginx running dan healthy
docker compose ps nginx

# Check nginx logs
docker compose logs nginx

# Test nginx dari dalam container
docker compose exec nginx wget -O- http://localhost:80
```

### 3. Check Network Connectivity

```bash
# Test dari cloudflared container ke nginx
docker compose exec cloudflared wget -O- http://nginx:80

# Test dari host ke nginx
curl http://localhost:80
```

### 4. Check Tunnel Token

```bash
# Pastikan token ada di .env
grep CLOUDFLARE_TUNNEL_TOKEN .env

# Test token validity (akan error jika invalid)
docker compose exec cloudflared cloudflared tunnel info
```

## ✅ Solusi

### Solusi 1: Pastikan Nginx Ready Sebelum Cloudflared Start

Docker Compose sudah dikonfigurasi dengan `depends_on` dan `condition: service_healthy`, tapi pastikan:

```bash
# Restart dengan urutan yang benar
docker compose down
docker compose up -d nginx
# Tunggu nginx ready
docker compose ps nginx  # Pastikan status "healthy"
docker compose up -d cloudflared
```

### Solusi 2: Update Cloudflare Tunnel Configuration

Edit `docker-compose.yml` untuk menambahkan retry dan timeout:

```yaml
cloudflared:
  image: cloudflare/cloudflared:latest
  container_name: warungin-cloudflared
  restart: unless-stopped
  command: tunnel --no-autoupdate run --retries 5
  environment:
    - TUNNEL_TOKEN=${CLOUDFLARE_TUNNEL_TOKEN:-}
  networks:
    - warungin-network
  depends_on:
    nginx:
      condition: service_healthy
  healthcheck:
    test: ["CMD", "cloudflared", "tunnel", "info"]
    interval: 30s
    timeout: 10s
    retries: 3
  profiles:
    - cloudflare
```

### Solusi 3: Regenerate Tunnel Token

Jika token expired atau invalid:

1. **Buka Cloudflare Dashboard:**
   - Zero Trust > Networks > Tunnels
   - Pilih tunnel Anda
   - Klik "Configure"

2. **Generate New Token:**
   - Klik "Create a tunnel"
   - Atau edit tunnel existing
   - Copy token baru

3. **Update .env:**
   ```bash
   nano .env
   # Update CLOUDFLARE_TUNNEL_TOKEN=your_new_token
   ```

4. **Restart Cloudflared:**
   ```bash
   docker compose restart cloudflared
   ```

### Solusi 4: Check Cloudflare Dashboard Configuration

Pastikan di Cloudflare Dashboard:

1. **Public Hostname:**
   - Domain: `pos.faiznute.site` (atau domain Anda)
   - Service: `http://nginx:80` (atau `http://localhost:80` jika di host)
   - **PENTING:** Gunakan `nginx:80` jika di Docker network, atau `localhost:80` jika di host

2. **Origin Configuration:**
   - Jika tunnel di Docker: `http://nginx:80`
   - Jika tunnel di host: `http://localhost:80`

### Solusi 5: Fix Network Configuration

Jika menggunakan Docker network, pastikan cloudflared bisa reach nginx:

```bash
# Test connectivity
docker compose exec cloudflared ping nginx

# Test HTTP
docker compose exec cloudflared wget -O- http://nginx:80
```

Jika tidak bisa connect, pastikan keduanya di network yang sama (`warungin-network`).

### Solusi 6: Restart dengan Clean State

```bash
# Stop semua
docker compose down

# Remove cloudflared container
docker rm -f warungin-cloudflared 2>/dev/null || true

# Start nginx dulu
docker compose up -d nginx

# Tunggu nginx ready (check logs)
docker compose logs -f nginx
# Tunggu sampai melihat "ready for connections"

# Start cloudflared
docker compose --profile cloudflare up -d cloudflared

# Check logs
docker compose logs -f cloudflared
```

## 🚀 Setup Cloudflare Tunnel dari Awal

### 1. Buat Tunnel di Cloudflare Dashboard

1. Login ke [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Pilih account Anda
3. Buka **Zero Trust** > **Networks** > **Tunnels**
4. Klik **Create a tunnel**
5. Pilih **Cloudflared**
6. Beri nama tunnel (contoh: `warungin-tunnel`)
7. Copy **Tunnel Token**

### 2. Configure Public Hostname

1. Di tunnel yang baru dibuat, klik **Configure**
2. Klik **Public Hostname** tab
3. Klik **Add a public hostname**
4. Isi:
   - **Subdomain:** `pos` (atau sesuai kebutuhan)
   - **Domain:** `faiznute.site` (domain Anda)
   - **Service:** `http://nginx:80` (jika di Docker) atau `http://localhost:80` (jika di host)
5. Klik **Save hostname**

### 3. Setup di Server

```bash
# Edit .env
nano .env

# Tambahkan:
CLOUDFLARE_TUNNEL_TOKEN=your_tunnel_token_here
```

### 4. Start Cloudflared

```bash
# Start dengan profile cloudflare
docker compose --profile cloudflare up -d cloudflared

# Check status
docker compose ps cloudflared
docker compose logs cloudflared
```

## 📋 Checklist Troubleshooting

- [ ] Nginx service running dan healthy
- [ ] Cloudflared container running
- [ ] Tunnel token valid dan tidak expired
- [ ] Network connectivity: cloudflared bisa reach nginx
- [ ] Cloudflare Dashboard: Public hostname configured dengan benar
- [ ] Origin service URL benar (`http://nginx:80` atau `http://localhost:80`)
- [ ] DNS record pointing ke Cloudflare (jika menggunakan custom domain)
- [ ] Firewall tidak block connection

## 🔄 Restart Services

```bash
# Restart cloudflared saja
docker compose restart cloudflared

# Restart semua dengan cloudflare profile
docker compose --profile cloudflare down
docker compose --profile cloudflare up -d

# Full restart
docker compose down
docker compose up -d nginx
sleep 10  # Tunggu nginx ready
docker compose --profile cloudflare up -d cloudflared
```

## 📊 Monitoring

### View Logs

```bash
# Cloudflared logs
docker compose logs -f cloudflared

# Nginx logs
docker compose logs -f nginx

# All services
docker compose logs -f
```

### Check Tunnel Status

```bash
# Di Cloudflare Dashboard
# Zero Trust > Networks > Tunnels > Your Tunnel
# Lihat status dan metrics
```

## 🆘 Masih Error?

1. **Check Cloudflare Status Page:** https://www.cloudflarestatus.com
2. **Check Tunnel Health di Dashboard:** Zero Trust > Networks > Tunnels
3. **Review Logs:** `docker compose logs cloudflared`
4. **Test Origin Directly:** `curl http://localhost:80` (harus berhasil)
5. **Regenerate Token:** Buat tunnel baru dan token baru

## 📚 Referensi

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Troubleshooting Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/troubleshooting/)
- [Error 1033 Documentation](https://developers.cloudflare.com/fundamentals/get-started/basic-tasks/status-codes/)

---

**Last Updated:** 2025-11-19  
**Domain:** pos.faiznute.site

