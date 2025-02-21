#!/bin/bash

# Fungsi untuk menginstal Subfinder
install_subfinder() {
  echo "Memeriksa apakah Subfinder sudah terpasang..."
  if ! command -v subfinder &> /dev/null; then
    echo "Subfinder tidak ditemukan. Mengunduh dan memasang Subfinder..."
    curl -s https://api.github.com/repos/projectdiscovery/subfinder/releases/latest | \
    grep "browser_download_url.*linux_amd64.zip" | cut -d '"' -f 4 | \
    wget -i - -O subfinder.zip
    unzip subfinder.zip
    chmod +x subfinder
    sudo mv subfinder /usr/local/bin/
    rm subfinder.zip
    echo "Subfinder berhasil dipasang!"
  else
    echo "Subfinder sudah terpasang."
  fi
}

# Fungsi untuk mengecek status HTTP
check_http_status() {
  INPUT_FILE=$1
  OUTPUT_FILE=$2
  echo "Memeriksa status HTTP untuk subdomain yang ditemukan..."
  
  while read -r subdomain; do
    STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$subdomain")
    if [ "$STATUS_CODE" -eq 200 ]; then
      echo "$subdomain" >> "$OUTPUT_FILE"
      echo "[200 OK] $subdomain"
    else
      echo "[SKIP] $subdomain (HTTP $STATUS_CODE)"
    fi
  done < "$INPUT_FILE"

  echo "Pengecekan selesai. Subdomain dengan status 200 OK disimpan di: $OUTPUT_FILE"
}

# Fungsi untuk menjalankan Subfinder
run_subfinder() {
  read -p "Masukkan domain target: " DOMAIN
  SUBDOMAINS_FILE="subdomains_$DOMAIN.txt"
  VALID_SUBDOMAINS_FILE="valid_subdomains_$DOMAIN.txt"

  echo "Menjalankan Subfinder untuk domain: $DOMAIN..."
  subfinder -d "$DOMAIN" -o "$SUBDOMAINS_FILE"

  if [ -f "$SUBDOMAINS_FILE" ]; then
    echo "Subdomain ditemukan. Memulai pengecekan HTTP status..."
    check_http_status "$SUBDOMAINS_FILE" "$VALID_SUBDOMAINS_FILE"
  else
    echo "Gagal menemukan subdomain. Periksa konfigurasi Subfinder."
  fi
}

# Fungsi untuk menampilkan menu
show_menu() {
  echo "==================================="
  echo "       SUBFINDER MENU UTAMA        "
  echo "==================================="
  echo "1. Instal Bahan Subfinder"
  echo "2. Scan Subfinder Domain"
  echo "3. Keluar"
  echo "==================================="
}

# Fungsi utama
main() {
  while true; do
    show_menu
    read -p "Pilih opsi [1-3]: " CHOICE
    case $CHOICE in
      1)
        install_subfinder
        ;;
      2)
        run_subfinder
        ;;
      3)
        echo "Keluar dari program. Sampai jumpa!"
        menu
        ;;
      *)
        echo "Opsi tidak valid, coba lagi."
        ;;
    esac
  done
}

# Menjalankan script utama
main
