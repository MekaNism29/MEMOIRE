# Echoes Back

Seseorang terbangun tanpa ingatan, tapi dia bukan sedang sadar. Dia ada di alam bawah sadarnya sendiri. Dia harus berjuang menghadapi berbagai trauma dan kenangan buruk masa lalunya supaya bisa kembali sadar ke dunia nyata.

Echoes Back adalah game 2D side-scrolling yang digabung dengan battle kartu per giliran. Dibuat dalam 48 jam untuk Hack Club, dengan tema "Bounce Back". Judul awalnya Memoire.

Idenya dari dua game: Hollow Knight (jalan dan lompat menjelajahi dunia) dan Slay the Spire (battle kartu). Kita gabungin keduanya supaya game-nya nggak cuma jalan dan lompat, tapi ada battle yang bikin pemain harus mikir.

## Soal tema Bounce Back

Buat kita, Bounce Back artinya bangkit dari titik paling bawah. Ada tiga bentuknya di game ini:

- **Mengalahkan bos tidak menghapus kenangannya.** Tiap bos yang kalah ngasih satu kartu baru ke dek pemain. Karakternya maju bareng lukanya, bukan ngelupain.
- **Mekanik Bounce Back di battle.** Makin dalam pemain terpuruk, makin besar damage pantulan yang bisa dikeluarkan (dijelasin di bawah).
- **Resilience Echo.** Setiap kali kalah, battle berikutnya kasih +1 Energi di giliran pertama (maksimal numpuk +2).

## Cara main

Pemain mulai di hub (Dasar Alam Bawah Sadar), lalu masuk ke tiga lapisan ingatan secara berurutan: Sekolah, Keluarga, dan Masa Kecil. Di ujung tiap lapisan ada gerbang bos. Tekan E untuk "Try to Remember", yaitu kilas balik singkat soal kenangan itu, lalu battle dimulai. Kalau ketiga bos kalah, muncul cahaya di hub dan game masuk ke ending.

### Battle

Tiap giliran kamu dapat 3 Energi dan 3 kartu. Bar nyawa diganti dengan **Balance**, pendulum emosi dari -10 sampai +10:

- Di bawah 0 itu "Terpuruk", di atas 0 itu "Meledak", dan 0 itu "Seimbang".
- Kalau Balance masih di -10 atau +10 waktu giliran bos selesai, kamu kalah.
- Menang kalau HP bos habis.

Bos tiap giliran mendorong Balance ke satu arah. Perisai dari kartu menyerap dorongan itu sebelum Balance bergeser.

**Bounce Back:** kalau Balance ada di antara -9 dan -7, kamu bisa mengorbankan satu kartu dari tangan. Pendulum langsung mental ke +1, dan bos kena damage sebesar jarak yang ditempuh. Contoh dari -8 ke +1 berarti 9 damage. Di -10 sudah nggak bisa, jadi jangan sampai kelewat jatuh.

### Kartu

Dek awal ada 10 kartu. Kartu tambahan datang dari hadiah bos.

| Kartu | Energi | Efek |
| --- | :---: | --- |
| Marah | 1 | 4 Damage, Balance +3 |
| Tenang | 1 | +4 Perisai, tarik Balance 2 poin ke arah 0 |
| Rindu | 1 | 2 Damage, tarik 1 kartu, Balance -1 |
| Takut | 0 | +2 Energi, Balance -3 |
| Bangga | 2 | 7 Damage dan +3 Perisai, Balance +2 |
| Kecewa | 1 | Dorongan bos berikutnya -3, Balance -2 |
| Lega | 1 | Tarik Balance 3 poin ke arah 0 |
| Kepingan Tekad | 1 | Tiap poin Balance negatif jadi +1 Perisai |
| Kepingan Hangat | 1 | Balance langsung ke 0, tarik 2 kartu |
| Kepingan Terima | 2 | 12 Damage, Balance langsung ke 0 |

Tiga kartu terakhir (Kepingan) cuma didapat dari bos.

### Bos

| Lapisan | Bos | HP | Pola | Hadiah |
| --- | --- | :---: | --- | --- |
| Sekolah | Bayangan Papan Tulis | 22 | Dorong Balance -2 tiap giliran | Kepingan Tekad |
| Keluarga | Meja Makan Sunyi | 27 | Gantian: -1 lalu +1 | Kepingan Hangat |
| Masa Kecil | Cermin Retak | 32 | Dorong +2, ditambah damage kartu terakhirmu dibagi 6 | Kepingan Terima |

Cermin Retak itu yang paling licik: makin besar damage kartu yang kamu pakai, makin kuat dia mendorong Balance ke kanan.

## Kontrol

| Aksi | Tombol |
| --- | --- |
| Jalan | A / D atau panah kiri / kanan |
| Lompat | Space, W, atau panah atas |
| Interaksi (Try to Remember, gerbang bos) | E atau Enter |
| Main kartu dan Bounce Back | Klik kiri mouse |

## Teknis

- Godot 4.7, 2D, renderer GL Compatibility
- Resolusi 1280 x 720
- Target: Web (itch.io) dan Windows
- Satu kali main sekitar 10 sampai 15 menit

Cara jalanin: buka Godot, Import, pilih `project.godot`, lalu tekan F5. Catatan pengembangan ada di `DEV_NOTES.md`.

## Tim

- **Mikael**: desain game (kartu, pola bos, naskah, audio, menu)
- **Fardan**: art dan UI (karakter, bos, latar, HUD, efek)
- **Rizki**: programmer (sistem battle, Balance, Bounce Back, gerak pemain, setup repo)

## Kredit

Dibuat oleh Mikael, Fardan, dan Rizki untuk Hack Club. Inspirasi: Hollow Knight dan Slay the Spire.

Sebagian pembuatan game ini dibantu AI.

Folder `assets/temporary/` masih berisi background dan tileset sementara.
