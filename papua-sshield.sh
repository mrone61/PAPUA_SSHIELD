#!/bin/bash
# ============================================
# Tools: PAPUA-SSHIELD
# Author: Mr One
# Community: Papua Cyber Community
# Version: V4 - Full Manual & Auto Secure
# Category: WhiteHat IAM & Hardening Toolkit
# Description: Secure SSH Key Provisioning
# Date: 2026
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_PATH="$0"
chmod 700 "$SCRIPT_PATH" 2>/dev/null

pause(){ read -p "Tekan Enter untuk lanjut..."; }

banner(){
 clear
 echo -e "${CYAN}================================================${NC}"
 echo -e "${CYAN} Tools: PAPUA-SSHIELD                           ${NC}"
 echo -e "${CYAN} Author: Mr One                                ${NC}"
 echo -e "${CYAN} Community: Papua Cyber Community               ${NC}"
 echo -e "${CYAN}================================================${NC}"
 PERM=$(ls -l "$SCRIPT_PATH" | awk '{print $1}')
 echo -e " File: ${YELLOW}$SCRIPT_PATH${NC}"
 echo -e " Permission: ${YELLOW}$PERM${NC} | IP: ${YELLOW}$(hostname -I | awk '{print $1}')${NC}"
 echo -e "${CYAN}================================================${NC}"
}

secure_perm_menu(){
 banner
 echo -e "${BLUE}=== AMANKAN PERMISSION SCRIPT ===${NC}"
 echo "Permission saat ini:"
 ls -l "$SCRIPT_PATH"
 echo ""
 echo "1. Set 700 (rwx------) -> Hanya Owner [REKOMENDASI]"
 echo "2. Set 750 (rwxr-x---) -> Owner + Group"
 echo "3. Cek detail permission"
 echo "0. Kembali"
 echo ""
 read -p "Pilih [0-3]: " p
 case $p in
  1) 
   chmod 700 "$SCRIPT_PATH"
   echo -e "${GREEN}[OK] Diamankan ke 700${NC}"
   ls -l "$SCRIPT_PATH"
   sleep 1
   echo -e "${YELLOW}Restart otomatis...${NC}"
   exec sudo "$SCRIPT_PATH"
   ;;
  2)
   chmod 750 "$SCRIPT_PATH"
   echo -e "${GREEN}[OK] Diamankan ke 750${NC}"
   ls -l "$SCRIPT_PATH"
   sleep 1
   exec sudo "$SCRIPT_PATH"
   ;;
  3) ls -l "$SCRIPT_PATH"; echo ""; ls -ld /home/*/.ssh 2>/dev/null; pause ;;
  0) return ;;
 esac
 pause
}

list_users(){
 echo -e "${BLUE}User di /home:${NC}"
 ls -l /home | awk '{print "  -> "$9" Perm: "$1}'
 echo ""
 echo -e "${BLUE}IP Laptop ini:${NC}"
 ip a | grep 192.168 | sed 's/^/  -> /'
}

install_ssh(){
 banner
 echo -e "${BLUE}[*] Install SSH Server...${NC}"
 sudo apt update && sudo apt install openssh-server -y
 sudo systemctl enable --now ssh
 echo -e "${GREEN}[OK] SSH Aktif${NC}"
 pause
}

create_user(){
 banner
 list_users
 echo ""
 read -p "Nama user baru: " u
 [[ -z "$u" ]] && return
 sudo adduser $u
 echo -e "${GREEN}[OK] User $u dibuat${NC}"
 pause
}

gen_key(){
 banner
 list_users
 echo ""
 read -p "Buat SSH Key untuk USER: " u
 if ! id "$u" &>/dev/null; then echo -e "${RED}User $u tidak ada!${NC}"; pause; return; fi
 sudo -u $u mkdir -p /home/$u/.ssh
 echo -e "${BLUE}Buat passphrase untuk $u (ENTER jika kosong):${NC}"
 sudo -u $u ssh-keygen -t ed25519 -C "$u@papua-cyber-community" -f /home/$u/.ssh/id_ed25519
 sudo chmod 700 /home/$u/.ssh
 sudo chmod 600 /home/$u/.ssh/id_ed25519
 sudo chmod 644 /home/$u/.ssh/id_ed25519.pub
 sudo chown -R $u:$u /home/$u/.ssh
 echo -e "${GREEN}[OK] Key $u selesai - 700/600 secured${NC}"
 pause
}

show_key(){
 banner
 list_users
 echo ""
 read -p "Lihat key milik USER (kosong = semua): " u
 if [[ -z "$u" ]]; then
   for user in $(ls /home); do
     echo -e "\n${YELLOW}== $user ==${NC}"
     sudo ls -l /home/$user/.ssh/ 2>/dev/null
     sudo cat /home/$user/.ssh/id_ed25519.pub 2>/dev/null || echo "Belum ada key"
   done
 else
   sudo ls -l /home/$u/.ssh/
   echo ""
   sudo cat /home/$u/.ssh/id_ed25519.pub 2>/dev/null || echo "Belum ada key"
 fi
 pause
}

copy_key(){
 banner
 echo -e "${BLUE}=== COPY PUBLIC KEY ===${NC}"
 list_users
 echo ""
 read -p "User PENGIRIM (laptop ini): " sender
 read -p "User PENERIMA (laptop tujuan): " receiver
 read -p "IP LAPTOP TUJUAN: " target_ip
 if [[ -z "$sender" || -z "$receiver" || -z "$target_ip" ]]; then echo -e "${RED}Semua harus diisi!${NC}"; pause; return; fi
 echo -e "${YELLOW}Proses: $sender -> $receiver@$target_ip${NC}"
 sudo -u $sender ssh-copy-id -i /home/$sender/.ssh/id_ed25519.pub $receiver@$target_ip
 pause
}

remote_ssh(){
 banner
 echo -e "${BLUE}=== REMOTE SSH ===${NC}"
 list_users
 echo ""
 read -p "Login SEBAGAI (laptop ini): " sender
 read -p "Login KE user (laptop tujuan): " receiver
 read -p "IP LAPTOP TUJUAN: " target_ip
 if [[ -z "$sender" || -z "$receiver" || -z "$target_ip" ]]; then echo -e "${RED}Semua harus diisi!${NC}"; pause; return; fi
 echo -e "${GREEN}ssh $receiver@$target_ip${NC}"
 sudo -u $sender ssh -i /home/$sender/.ssh/id_ed25519 $receiver@$target_ip
 pause
}

view_log(){
 banner
 echo -e "${BLUE}Permission script:${NC}"
 ls -l "$SCRIPT_PATH"
 echo ""
 list_users
 echo ""
 read -p "Cek authorized_keys milik USER (kosong = semua): " u
 if [[ -z "$u" ]]; then
   for user in $(ls /home); do
     echo -e "\n${YELLOW}-- $user : authorized_keys --${NC}"
     sudo cat /home/$user/.ssh/authorized_keys 2>/dev/null || echo "Kosong"
   done
 else
   sudo ls -l /home/$u/.ssh/
   sudo cat /home/$u/.ssh/authorized_keys 2>/dev/null || echo "Kosong"
 fi
 echo -e "\n${BLUE}Log login (bukti):${NC}"
 sudo grep "Accepted publickey" /var/log/auth.log | tail -n 10
 pause
}

while true; do
 banner
 echo " 1. Install SSH Server"
 echo " 2. Buat User Baru (manual input)"
 echo " 3. Buat SSH Key (manual user)"
 echo " 4. Lihat Public Key"
 echo " 5. Copy Public Key ke Teman (User & IP manual)"
 echo " 6. Remote ke Teman (User & IP manual)"
 echo " 7. Lihat Hasil & Log Bukti"
 echo " 8. Cek Daftar User & IP"
 echo " 9. Amankan Permission (read:4 write:2 excute:1)"
 echo " 0. Keluar"
 echo ""
 echo -e "${CYAN}================================================${NC}"
 read -p " Pilih [0-9]: " c
 case $c in
  1) install_ssh ;;
  2) create_user ;;
  3) gen_key ;;
  4) show_key ;;
  5) copy_key ;;
  6) remote_ssh ;;
  7) view_log ;;
  8) banner; list_users; pause ;;
  9) secure_perm_menu ;;
  0) chmod 700 "$SCRIPT_PATH"; echo -e "${GREEN}Salam Papua Cyber Community! - Mr One${NC}"; exit 0 ;;
  *) echo "Salah pilih"; pause ;;
 esac
done
