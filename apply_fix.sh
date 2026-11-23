#!/system/bin/sh
# ============================================================
# WebScreen 1.0.51 — Lag Fix untuk HP Low-End (Helio G25/G35)
# Tested: Infinix Hot 9 Play
# ============================================================

# Path utama dari hasil decompile native .so
BASE="/storage/emulated/0/Android/data/org.levimc.launcher/files"

echo "=== WebScreen Lag Fix ==="
echo ""

# Cek apakah folder ada
if [ ! -d "$BASE" ]; then
  echo "ERROR: Folder $BASE tidak ditemukan."
  echo "Pastikan LeviMC Launcher sudah diinstall dan dijalankan minimal sekali."
  exit 1
fi

echo "Folder config: $BASE"
echo ""

# FIX 1: Software render mode
# Efek: matikan lockHardwareCanvas() yang blok GPU di Helio G25/G35
# Trade-off: render WebView sedikit lebih lambat tapi TIDAK lag Minecraft
if touch "$BASE/ws_sw" 2>/dev/null; then
  echo "[OK] ws_sw — Software render aktif (hilangkan hardware canvas stall)"
else
  echo "[GAGAL] Tidak bisa buat $BASE/ws_sw — coba jalankan sebagai root atau pakai file manager"
fi

echo ""
echo "=== Selesai ==="
echo "Restart Minecraft untuk efek."
echo ""
echo "Mau balik ke hardware mode? Hapus file: $BASE/ws_sw"
