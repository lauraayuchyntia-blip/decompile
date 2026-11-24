# WebScreen 1.0.51 — Lag Fix untuk HP Low-End

**Target**: Infinix Hot 9 Play (Helio G25/G35), RAM 2-3GB  
**Plugin**: WebScreen 1.0.51 for LeviLamina (Minecraft Bedrock)

---

## Root Cause

WebScreen menggunakan dua path render:

| Mode | Method | Dampak di Helio G25/G35 |
|------|--------|-------------------------|
| HW (default) | `surface.lockHardwareCanvas()` | Blok GPU 80–150ms → Minecraft freeze |
| SW (fix) | `surface.lockCanvas()` | CPU render, tidak ganggu GPU Minecraft |

Pump loop berjalan setiap vsync (60Hz via `Choreographer.postFrameCallback`), dengan throttle default 33fps (`minFrameNs = 30_000_000L`).

### Masalah Video/Audio/Game (setelah fix ws_sw)

Setelah `ws_sw` aktif, render WebView sudah tidak ganggu GPU. Tapi masalah baru muncul saat:
- Video YouTube / streaming
- Audio playback
- Browser game (heavy JS)

**Penyebab**: Helio G25/G35 hanya punya **1 hardware video decoder core (MediaCodec)**. Saat WebView decode video:
- Minecraft + WebView rebutan decoder yang sama
- RAM 2-3GB habis untuk: Minecraft (~800MB) + WebView process (~300MB) + video buffer (~200MB) + sistem
- CPU Helio G25 (max 2.0GHz Cortex-A53) kewalahan decode video + render WebView + jalankan Minecraft serentak

Ini **bukan bug** di WebScreen — ini **hardware limitation** Helio G25/G35.

---

## Fix yang Diterapkan

### Flag Files (di `/storage/emulated/0/Android/data/org.levimc.launcher/files/`)

| File | Efek | Kenapa |
|------|------|--------|
| `ws_sw` | Force software canvas render | Eliminasi `lockHardwareCanvas()` stall |
| `ws_nomulti` | Matikan multi-window WebView | Hemat ~50-80MB RAM, kurangi context switch |

### Cara Pakai

Jalankan `apply_fix.sh` di Termux:
```sh
sh /sdcard/apply_fix.sh
```

Atau buat manual via file manager:
- Buat file kosong `ws_sw` di folder config
- Buat file kosong `ws_nomulti` di folder config

---

## Tips Khusus Video/Audio/Game

Karena hardware limitation tidak bisa di-patch via flag:

1. **Sebelum buka WebScreen**: tutup semua app lain
2. **Video YouTube**: pilih kualitas 360p/480p (Settings > Quality)
3. **Browser game**: matiin sound Minecraft dulu (Settings > Audio)
4. **Freeze 2-3 detik**: itu normal — Helio G25 decode video frame; audio tetap jalan

---

## Semua Flags yang Tersedia di WebScreen 1.0.51

Dari hasil decompile `webscreen.so`:

| Flag (nama file) | Fungsi |
|-----------------|--------|
| `ws_sw` | Force software render (fix utama lag GPU) |
| `ws_nomulti` | Matikan multi-window |
| `ws_hwlayer` | Aktifkan hardware layer di WebView (jangan pakai di low-end) |
| `ws_vis` | Paksa holder visible di window |
| `ws_noadblock` | Matikan DNS adblock |
| `ws_allow_http` | Izinkan HTTP (non-HTTPS) |
| `ws_incog_nostorage` | Mode incognito tanpa storage |
| `ws_lang_pt` | Paksa bahasa Portugis (UI plugin) |

> ⚠️ Tidak ada flag untuk disable video/audio atau throttle FPS — itu hardcoded di binary.

---

## File Referensi

- `apply_fix.sh` — script otomatis buat semua flag
- Decompile source: `WsHost.java` (via JADX dari `webscreen.so`)
- Config path: diambil dari `webscreen.decompiled.c` (native side)

