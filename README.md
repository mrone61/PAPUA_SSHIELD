# PAPUA-SSHIELD - Papua Secure Shell Shield


## 1. Deskripsi Tools

PAPUA-SSHIELD adalah sebuah toolkit otomatisasi berbasis Bash Script yang dirancang untuk mengelola dan mengamankan akses SSH menggunakan metode Public Key Authentication.

Dalam administrasi Linux, untuk menghubungkan satu laptop ke laptop lain tanpa password, administrator harus melakukan beberapa langkah manual yaitu membuat SSH Key dengan perintah ssh-keygen, mengatur permission folder .ssh menjadi 700 dan private key menjadi 600, kemudian mendistribusikan public key ke laptop tujuan menggunakan ssh-copy-id dengan format user@IP.

Proses manual tersebut sering menimbulkan kesalahan seperti lupa mengatur permission sehingga muncul error UNPROTECTED PRIVATE KEY FILE, salah ketik IP tujuan, dan tidak ada log yang jelas sebagai bukti.

PAPUA-SSHIELD hadir untuk menyelesaikan masalah tersebut. Semua proses manual diubah menjadi sistem menu interaktif. User hanya perlu memilih angka menu dan memasukkan nama user serta IP secara manual. Tools ini akan otomatis menjalankan perintah Linux yang sesuai, melakukan hardening permission, dan menampilkan log bukti keberhasilan.

Nama PAPUA-SSHIELD memiliki arti:
PAPUA adalah identitas pembuat yaitu Papua Cyber Community.
SSH adalah Secure Shell yaitu protokol yang diamankan.
SHIELD adalah perisai yaitu fungsi hardening dan lockdown permission.

## 2. Tujuan Pembuatan Tools

Tools ini dibuat dengan tujuan utama:

a. Memudahkan provisioning akses SSH. Mengotomatisasi pembuatan SSH Key pair dengan algoritma Ed25519 yang lebih aman dan cepat dibandingkan RSA.

b. Melakukan hardening secara otomatis. Setiap kali key dibuat, folder /home/user/.ssh otomatis dikunci dengan permission 700 (rwx------) dan file private key dikunci dengan 600 (rw-------). Jika permission tidak sesuai standar, OpenSSH akan menolak koneksi.

c. Memberikan fleksibilitas untuk tim. Menu Copy Key dan Remote SSH meminta input manual untuk User Pengirim, User Penerima, dan IP Tujuan. Sehingga tools ini bisa digunakan untuk skenario 3 laptop atau lebih dengan user dan IP yang berbeda-beda tanpa harus mengedit script.

d. Menyediakan fitur audit dan bukti. Melalui menu Lihat Hasil & Log, user dapat melihat isi file authorized_keys dan log sistem di /var/log/auth.log yang mencatat Accepted publickey sebagai bukti sah bahwa login tanpa password berhasil.

e. Mengamankan tools itu sendiri. Melalui Menu 9, script dapat mengamankan dirinya sendiri menjadi permission 700 (hanya owner yang bisa baca tulis eksekusi) atau 750 (owner full, group bisa baca eksekusi). Setelah permission diubah, script akan otomatis melakukan exec atau restart dengan permission aman tersebut.

## 3. Fitur Lengkap dan Fungsi Tiap Menu

Menu 1 - Install SSH Server
Fungsinya untuk menginstall paket openssh-server, kemudian mengaktifkan dan menjalankan service ssh. Perintah yang dijalankan adalah apt update, apt install openssh-server -y, dan systemctl enable --now ssh. Tanpa ini laptop tidak bisa menerima koneksi SSH dari laptop lain.

Menu 2 - Buat User Baru
Fungsinya untuk membuat user Linux baru di direktori /home. Perintah yang dijalankan adalah adduser. Menu ini dibuat manual karena pada tugas 3 laptop, tiap laptop memiliki nama user yang berbeda.

Menu 3 - Buat SSH Key (Fitur Inti)
Fungsinya untuk membuat pasangan kunci SSH. Langkah yang dilakukan tools adalah membuat folder /home/user/.ssh, menjalankan ssh-keygen -t ed25519 dengan comment user@papua-cyber-community, kemudian mengatur permission chmod 700 untuk folder, chmod 600 untuk private key id_ed25519, chmod 644 untuk public key id_ed25519.pub, dan chown -R user:user. Ini adalah inti dari keamanan SSH.

Menu 4 - Lihat Public Key
Fungsinya untuk menampilkan isi file public key id_ed25519.pub menggunakan perintah cat. User bisa memilih untuk melihat key milik satu user tertentu atau semua user yang ada di /home. Ini berguna untuk verifikasi sebelum dikirim ke teman.

Menu 5 - Copy Public Key ke Teman (Fitur Inti)
Fungsinya untuk mendistribusikan public key ke laptop tujuan. Tools akan meminta 3 input manual yaitu User Pengirim (user di laptop ini), User Penerima (user di laptop tujuan), dan IP Laptop Tujuan. Kemudian menjalankan perintah ssh-copy-id -i /home/pengirim/.ssh/id_ed25519.pub penerima@IP. Setelah berhasil, public key akan masuk ke file /home/penerima/.ssh/authorized_keys di laptop tujuan.

Menu 6 - Remote ke Teman
Fungsinya untuk menguji apakah copy key berhasil. Tools meminta input Login Sebagai, Login Ke, dan IP Tujuan. Kemudian menjalankan ssh -i /home/pengirim/.ssh/id_ed25519 penerima@IP. Jika konfigurasi benar, user akan langsung login tanpa diminta password.

Menu 7 - Lihat Hasil & Log Bukti
Fungsinya untuk audit. Menampilkan permission script saat ini dengan ls -l, menampilkan isi authorized_keys tiap user, dan menampilkan log login dengan perintah grep Accepted publickey /var/log/auth.log. Log ini menjadi bukti untuk laporan tugas.

Menu 8 - Cek Daftar User & IP
Fungsinya untuk membantu user agar tidak salah input. Menampilkan daftar user di /home beserta permissionnya dan menampilkan IP lokal dengan ip a | grep 192.168.

Menu 9 - Amankan Permission 700/750 & Auto Run
Fungsinya untuk mengamankan file script itu sendiri. User dapat memilih Set 700 (rwx------) yang artinya hanya owner yang bisa baca tulis eksekusi, ini adalah yang paling direkomendasikan. Atau Set 750 (rwxr-x---) yang artinya owner full akses, group bisa baca dan eksekusi. Setelah memilih, tools akan menjalankan chmod 700 atau 750 dan otomatis melakukan exec sudo bash $0 untuk menjalankan ulang script dengan permission yang baru.

## 4. Cara Penggunaan Lengkap

Persiapan Awal:
Pastikan menggunakan OS Linux seperti Kali Linux, Ubuntu, atau Debian dan memiliki akses sudo.

Langkah Instalasi:
1. Clone repository dari GitHub: git clone https://github.com/mrone61/PAPUA_SSHIELD.git
2. Masuk ke direktori: cd PAPUA_SSHIELD
3. Perbaiki format file jika sebelumnya diedit di Windows agar tidak error $'\r': jalankan perintah sed -i 's/\r$//' papua-sshield.sh atau dos2unix papua-sshield.sh
4. Beri hak eksekusi: chmod +x papua_sshield.sh
5. Jalankan tools: sudo bash papua_sshield.sh
6. Pada saat pertama kali masuk menu, pilih Menu 9 lalu pilih 1 untuk mengatur permission menjadi 700. Script akan otomatis restart.

Skenario Penggunaan untuk 3 Laptop:
Misalkan ada Laptop A IP 192.168.1.10 user mrone, Laptop B IP 192.168.1.11 user tono, Laptop C IP 192.168.1.12 user agus.

Di Laptop A:
- Pilih Menu 1 untuk install SSH Server
- Pilih Menu 3, masukkan user mrone untuk membuat key
- Pilih Menu 5, masukkan Pengirim mrone, Penerima tono, IP 192.168.1.11
- Pilih Menu 5 lagi, masukkan Pengirim mrone, Penerima agus, IP 192.168.1.12
- Pilih Menu 6 untuk tes remote ke tono@192.168.1.11 dan agus@192.168.1.12

Lakukan langkah yang sama secara silang di Laptop B dan Laptop C agar ketiga laptop saling terhubung tanpa password (Full Mesh).

## 5. Konsep Keamanan Permission

Kenapa harus 700 dan 600:
Folder ~/.ssh harus 700. Jika permissionnya 755 atau 777, OpenSSH akan menganggap tidak aman dan menolak.
File private key id_ed25519 harus 600. Hanya owner yang boleh membaca. Jika 644, akan muncul error WARNING UNPROTECTED PRIVATE KEY FILE.
File public key id_ed25519.pub harus 644.
File script papua_sshield.sh 700 artinya rwx------ hanya owner yang bisa akses, ini paling aman untuk file yang berhubungan dengan akses privat.

## 6. Bukti Keberhasilan

Setelah berhasil, pada Menu 7 akan terlihat isi authorized_keys yang berisi baris ssh-ed25519 AAAAC3... user@papua-cyber-community dan pada log auth.log akan muncul baris Accepted publickey for tono from 192.168.1.10 port xxxxx ssh2. Screenshot log tersebut dapat digunakan sebagai bukti laporan.

## 7. Kategori Cyber Security

Tools ini termasuk dalam kategori IAM Automation, Privileged Access Management, Server Hardening, dan WhiteHat Toolkit untuk Initial Access Provisioning secara etis.

## 8. Informasi Community

Dibuat oleh Mr One dari Papua Cyber Community. Sebuah komunitas WhiteHat Cyber Security dari Tanah Papua yang berfokus pada edukasi keamanan siber.

## 9. Lisensi

MIT License
Copyright (c) 2026 Mr One - Papua Cyber Community

Izin diberikan secara gratis kepada siapa pun yang mendapatkan salinan perangkat lunak ini untuk menggunakan, menyalin, memodifikasi, menggabungkan, menerbitkan, mendistribusikan, dan menjual salinan perangkat lunak, dengan syarat mencantumkan pemberitahuan hak cipta dan izin ini di semua salinan.

Perangkat lunak ini disediakan apa adanya, tanpa jaminan apapun.

## 10. Disclaimer & Etika Penggunaan

PAPUA-SSHIELD dibuat hanya untuk tujuan edukasi, tugas kuliah, dan administrasi server milik sendiri yang sah (WhiteHat).

1. Gunakan Hanya di Lab Sendiri: Tools ini hanya boleh digunakan untuk menghubungkan laptop milik sendiri, VM lab, atau server yang kamu kelola dengan izin resmi. Contoh: 3 laptop tugas kuliah, server kantor sendiri.

2. Dilarang Untuk Akses Ilegal: Dilarang keras menggunakan tools ini untuk mengirim public key ke server, laptop, atau sistem milik orang lain tanpa izin tertulis dari pemiliknya. Mengakses sistem tanpa izin adalah pelanggaran hukum UU ITE No 11 Tahun 2008 dan dapat dipidana.

3. Untuk Apa Disclaimer Ini Dibuat: Karena tools SSH Key adalah tools sensitif yang berhubungan dengan akses sistem. Jika disalahgunakan, seseorang bisa saja mengirimkan kuncinya ke server orang lain untuk mendapatkan akses ilegal. Disclaimer ini dibuat untuk menegaskan bahwa tools ini adalah untuk pembelajaran hardening, bukan untuk peretasan. Tujuannya juga untuk melindungi pembuat tools agar tidak bertanggung jawab jika ada pihak yang menyalahgunakan.

4. Tanggung Jawab Pengguna: Author Mr One dan Papua Cyber Community tidak bertanggung jawab atas segala penyalahgunaan, kerusakan sistem, atau pelanggaran hukum yang dilakukan oleh pengguna tools ini. Segala risiko ditanggung oleh pengguna sendiri.

Dengan menggunakan PAPUA SSHIELD, berarti kamu setuju untuk menggunakannya secara etis dan legal sebagai WhiteHat.

---
Dibuat dengan bangga dari Tanah Papua untuk Indonesia.
