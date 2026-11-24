#!/system/bin/sh
# ============================================================
# WebScreen 1.0.51 — Lag Fix untuk HP Low-End (Helio G25/G35)
# Tested: Infinix Hot 9 Play
# Fix v2: tambah flag ws_nomulti untuk hemat RAM saat video
# ============================================================

BASE="/storage/emulated/0/Android/data/org.levimc.launcher/files"

echo "=== WebScreen Lag Fix v2 ==="
echo ""

if [ ! -d "$BASE" ]; then
  echo "ERROR: Folder $BASE tidak ditemukan."
  echo "Pastikan LeviMC Launcher sudah diinstall dan dijalankan minimal sekali."
  exit 1
fi

echo "Folder config: $BASE"
echo ""

# FIX 1: Software render mode
# Matiin lockHardwareCanvas() — cegah GPU stall di Helio G25/G35
if touch "$BASE/ws_sw" 2>/dev/null; then
  echo "[OK] ws_sw — Software render aktif (cegah GPU freeze)"
else
  echo "[GAGAL] ws_sw — coba jalankan sebagai root atau pakai file manager"
fi

# FIX 2: Nonaktifkan multi-window WebView
# Hemat RAM ~50-80MB, kurangi context switching saat video/game jalan
if touch "$BASE/ws_nomulti" 2>/dev/null; then
  echo "[OK] ws_nomulti — Multi-window mati (hemat RAM untuk video/game)"
else
  echo "[GAGAL] ws_nomulti"
fi

echo ""
echo "=== Tips Penggunaan (PENTING untuk video/game) ==="
echo ""
echo "Karena Helio G25/G35 cuma punya 1 hardware video decoder:"
echo ""
echo "  1. Sebelum buka WebScreen: tutup semua app lain dulu"
echo "  2. Untuk video YouTube: pilih kualitas 360p atau 480p"
echo "     (klik Settings di YouTube > Quality > 360p)"
echo "  3. Untuk browser game: matikan suara Minecraft dulu"
echo "     (Settings > Audio > matiin Music dan Sound)"
echo "  4. Kalau masih freeze: tunggu 2-3 detik, audio tetap jalan"
echo "     itu normal — Helio G25 lagi nge-decode frame video"
echo ""
echo "=== Selesai ==="
echo "Restart Minecraft untuk efek fix."
echo ""
echo "Mau reset? Hapus file-file ini:"
echo "  rm $BASE/ws_sw"
echo "  rm $BASE/ws_nomulti"
