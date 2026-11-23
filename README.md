# WebScreen Lag Fix — Infinix Hot 9 Play

Fix lag WebScreen 1.0.51 di HP low-end (Helio G25/G35).

## Penyebab Lag (dari hasil decompile)

Ditemukan 3 bug di `WsHost.java`:

### Bug #1 — `pumpHw()` lock hardware canvas di main thread tiap frame
```java
// WsHost.java line ~6213 — jalan SETIAP frame Choreographer
Canvas lockHardwareCanvas = surface.lockHardwareCanvas();
frameLayout.draw(lockHardwareCanvas);  // ← BLOK main thread 80-150ms di GPU lemah
surface.unlockCanvasAndPost(lockHardwareCanvas);
```
Di Helio G25/G35, GPU bandwidth sempit → stall hingga 150ms pas buka halaman baru atau buka menu WebScreen.

### Bug #2 — Choreographer loop jalan terus meski WebView belum siap
```java
// doFrame() selalu re-schedule meski `painted = false`
Choreographer.getInstance().postFrameCallback(this);
```

### Bug #3 — `minFrameNs` default 30ms (33 FPS) terlalu agresif
```java
private static volatile long minFrameNs = 30000000; // 30ms default
```

## Solusi

WebScreen membaca **flag dari file kosong** di folder:
```
/storage/emulated/0/Android/data/org.levimc.launcher/files/
```

### Fix: Buat file `ws_sw`
File kosong ini memaksa WebScreen pakai **software render** → tidak ada `lockHardwareCanvas()` → tidak ada stall di main thread.

## Cara Pakai

### Otomatis (via script)
Jalankan `apply_fix.sh` di terminal Android (Termux, dll):
```sh
sh apply_fix.sh
```

### Manual (via file manager)
Buat file kosong bernama `ws_sw` di:
```
/storage/emulated/0/Android/data/org.levimc.launcher/files/ws_sw
```

Restart Minecraft.

### Balik ke normal
Hapus file `ws_sw` dari folder tersebut.

## Catatan
- Dicoba di: Infinix Hot 9 Play (Helio G25, Android 11)
- WebScreen versi: 1.0.51
- Lag hilang: saat buka menu WebScreen & saat buka halaman web baru
