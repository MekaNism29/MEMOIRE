# MEMOIRE

> *"Seorang manusia biasa terbangun tanpa ingatan di kedalaman alam bawah sadarnya sendiri; alih-alih menghapus luka masa lalu, ia harus menghadapi setiap trauma, memantul balik dari keterpurukan emosional, dan menyerap setiap ingatan pahit menjadi kekuatan untuk kembali bangun ke dunia nyata."*

**MEMOIRE** *(judul kerja sebelumnya: Echoes Back)* adalah game aksi-petualangan eksplorasi **2D side-scrolling** yang dipadukan dengan pertarungan kartu taktis berbasis giliran (**turn-based deckbuilding**). Dibangun dalam waktu **48 jam** untuk ajang **Hack Club** dengan tema **"Bounce Back"**.

---

## 📖 Daftar Isi
- [Interpretasi Tema: "Bounce Back"](#-interpretasi-tema-bounce-back)
- [Cerita & Struktur Dunia](#-cerita--struktur-dunia)
- [Gameplay & Sistem Emotional Balance](#-gameplay--sistem-emotional-balance)
- [Daftar 10 Kartu Emosi & Resiliensi](#-daftar-15-kartu-emosi--resiliensi)
- [Daftar 3 Bos Trauma](#-daftar-3-bos-trauma)
- [Spesifikasi Teknis & Kontrol](#-spesifikasi-teknis--kontrol)
- [Tim & Pembagian Tugas](#-tim--pembagian-tugas)
- [Roadmap Produksi 48 Jam](#-roadmap-produksi-48-jam)
- [Panduan Setup & Kolaborasi Git (Godot 4)](#-panduan-setup--kolaborasi-git-godot-4)

---

## 🔄 Interpretasi Tema: "Bounce Back"
Dalam game ini, **Bounce Back** diterjemahkan sebagai **resiliensi psikologis**—kemampuan manusia untuk berdamai dengan rasa sakit, memantul kembali dari titik emosional terendah, dan mengubah luka menjadi kekuatan baru.

1. **Absorb, Bukan Menghapus:** Mengalahkan bos trauma tidak melenyapkan ingatan tersebut, melainkan meleburnya menjadi **Kartu Resiliensi** baru di dalam *deck* pemain. Karakter utama bangkit *bersama* lukanya.
2. **Mekanik Pantulan Kritis (*Bounce Back*):** Semakin dalam pemain terpuruk mendekati titik keputusasaan, semakin besar daya pantul serangan balik yang dapat dilepaskan untuk membalikkan keadaan.
3. **Resilience Echo:** Kekalahan bukanlah akhir. Setiap kali kalah, pemain meninggalkan jejak resiliensi yang memberi bonus energi pada percobaan berikutnya.

---

## 🌌 Cerita & Struktur Dunia
* **Premis:** Karakter utama terbangun tanpa nama dan ingatan di ruang gelap alam bawah sadarnya. Ingatannya pecah menjadi **Kepingan Emosi** (kartu aksi) dan **Kepingan Trauma** (bos penjaga lapisan ingatan).
* **Peta Hub-and-Spoke:** Pemain memulai dari **1 Hub Utama (Dasar Alam Bawah Sadar)** yang terhubung ke **3 Lapisan Ingatan** linear:
  1. **Lapisan Sekolah**
  2. **Lapisan Keluarga**
  3. **Lapisan Masa Kecil**
* **Ending:** Setelah ketiga trauma diserap, retakan cahaya muncul di langit-langit alam bawah sadar. Palet warna berubah dari monokrom redup menjadi hangat keemasan, dan karakter terbangun kembali di dunia nyata.

---

## ⚔️ Gameplay & Sistem Emotional Balance

### 1. Eksplorasi & Prompt *"Try to Remember"*
Pemain menelusuri lorong 2D side-scrolling untuk menelusuri lorong singkat menuju Bos Trauma di ujung area, muncul tombol interaktif **"Try to Remember"** yang memicu kilas balik singkat mengenai akar trauma sebelum masuk ke arena pertarungan berbasis giliran.

### 2. Meteran *Emotional Balance* (`-10` s/d `+10`)
Pengganti *Health Bar* konvensional berbentuk skala pendulum emosi:
* **Zona Kiri (`-10` s/d `-1` — Terpuruk / Apatis):** Kesedihan dan keputusasaan. Membuka akses mekanik *Bounce Back* saat berada di angka `-7` hingga `-9`.
* **Zona Tengah (`0` — Seimbang):** Titik stabilitas batin ideal.
* **Zona Kanan (`+1` s/d `+10` — Overwhelmed / Meledak):** Amarah berlebih dan impulsivitas. Daya serang tinggi namun berisiko menyentuh batas ekstrem.

> **⚡ Mekanik Utama — BOUNCE BACK:**
> Ketika *Emotional Balance* jatuh ke **Zona Kritis (`-7` hingga `-9`)**, tombol reaksi **`BOUNCE BACK`** menyala. Dengan mengorbankan **1 kartu** dari tangan, jarum pendulum memantul instan menuju **`+1`** sekaligus melepaskan **Recoil Damage** sebesar total poin pantulan (contoh: dari `-8` ke `+1` = **9 Damage murni** menembus pertahanan bos).

* **Kondisi Menang:** Menghabiskan *Trauma Shield* / HP Bos.
* **Kondisi Kalah:** Jarum pendulum menyentuh **`-10`** atau **`+10`** dan bertahan di sana hingga akhir giliran musuh.

---

## 🃏 10 Jenis Kartu Emosi & Resiliensi
Setiap giliran pemain mendapatkan **3 Energi** dan menarik **3 Kartu**.

| Nama Kartu | Energi | Efek |
| :--- | :---: | :--- |
| **Marah** | 1 | 4 Damage, Balance +3. |
| **Tenang** | 1 | +4 Shield, Balance 2 poin mendekati 0. |
| **Rindu** | 1 | 2 Damage, tarik 1 kartu, Balance -1. |
| **Takut** | 0 | +2 Energi, Balance -3. |
| **Bangga** | 2 | 7 Damage + 3 Shield, Balance +2. |
| **Kecewa** | 1 | Kurangi dorongan bos berikutnya 3 poin, Balance -2. |
| **Lega** | 1 | Tarik Balance 3 poin mendekati 0. |
| **Kepingan Tekad** | 1 | Ubah tiap poin Balance negatif menjadi +1 Shield. |
| **Kepingan Hangat** | 1 | Pulihkan Balance ke 0 dan tarik 2 kartu. |
| **Kepingan Terima** | 2 | 12 Damage dan pulihkan Balance ke 0. |

---

## 👹 Daftar 3 Bos Trauma

| Lapisan Area | Nama Bos Trauma | HP / Shield | Kilas Balik *"Try to Remember"* | Pola Serangan Bos | Hadiah Kartu |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **1. Sekolah** | **Bayangan Papan Tulis** | `28` | Gema bel sekolah, kertas ujian penuh coretan merah, dan rasa takut mengecewakan ekspektasi. | Menyerang mental secara konsisten (geser Balance **`-2`** tiap giliran) ke jurang apatis. | **Kepingan Tekad** |
| **2. Keluarga** | **Meja Makan Sunyi** | `35` | Detak jam dinding di ruang makan yang sepi dan kalimat penting yang tak pernah terucap. | Menekan Balance bergantian (`-1` / `+1`). | **Kepingan Hangat** |
| **3. Masa Kecil** | **Cermin Retak** | `42` | Sosok kecil yang bersembunyi di sudut kamar gelap karena takut melangkah keluar. | Meniru nilai serangan kartu terakhir pemain & mendorong Balance ke kanan (**`+2`** ditambah sebagian damage kartu terakhir). | **Kepingan Terima** |

---

## 🛠️ Spesifikasi Teknis & Kontrol

* **Engine:** Godot 4 (2D)
* **Target Platform:** Web (**HTML5 / itch.io**) & Desktop (**Windows `.exe`**)
* **Resolusi Dasar:** `1280 x 720`
* **Gaya Visual:** Pixel art atmosferik gelap (biru kelabu) dengan aksen cahaya pada lingkungan dan efek *Bounce Back*.
* **Estimasi Durasi:** 10–15 menit per *run* penuh.

### Kontrol Dasar
| Aksi | Tombol |
| :--- | :--- |
| Bergerak Kiri / Kanan | `A` / `D` atau `Panah Kiri` / `Panah Kanan` |
| Lompat | `Space` atau `W` |
| Interaksi (*Try to Remember* / Ambil Kepingan) | `E` atau `Enter` |
| Mainkan Kartu / Aktifkan *Bounce Back* | `Klik Kiri Mouse` |

---

## 👥 Tim & Pembagian Tugas

| Anggota | Peran Utama | Tanggung Jawab Utama & Dukungan Koding |
| :--- | :--- | :--- |
| **Mikael** | **Head Programmer**<br>*(Core Systems & Architecture)* | • Memimpin arsitektur kode, setup repository Git, dan merge branch.<br>• Membangun *state machine* pertarungan berbasis giliran, sistem *deck/hand/discard*, logika skala pendulum *Emotional Balance*, mekanik *Bounce Back*, serta kontrol gerak 2D. |
| **Fardan** | **Artistic & Support Programmer**<br>*(Visual, Animasi & UI Code)* | • **Art:** Menggambar karakter utama, 3 sprite Bos Trauma, tileset/latar 3 lorong ingatan, ikon kartu, serta desain HUD.<br>• **Support Code:** Menulis skrip animasi, *binding* UI HUD (jarum pendulum & kartu), efek *juice* (*screen shake*, partikel), serta perakitan *level* di Godot. |
| **Rizki** | **Game Designer & Support Programmer**<br>*(Gameplay, Data & Audio Code)* | • **Design:** Merancang *balancing* 10 jenis kartu, pola serangan bos, menulis naskah *"Try to Remember"* & *Codex*, serta meracik BGM/SFX.<br>• **Support Code:** Membuat database kartu (`.json`/`.tres`), logika efek spesifik kartu & AI bos, *Dialogue System*, *Codex*, *Main Menu*, dan *Audio Manager*. |

---

## ⏱️ Roadmap Produksi 48 Jam

### Hari 1: Fondasi, Mekanik Inti & *Vertical Slice* (Jam 00 – 24)
- [ ] **Jam 00 – 03 (Setup & Kickoff):** Freeze scope GDD, setup repo GitHub & struktur folder Godot (`1280x720`), siapkan *placeholder* visual, finalisasi 10 jenis kartu & dialog bos.
- [ ] **Jam 03 – 10 (Core Prototyping):** *State machine* pertarungan, *draw/energy*, kalkulasi *Emotional Balance* (Mikael); sprite karakter utama, tileset lorong, bingkai kartu (Fardan); struktur JSON 10 jenis kartu & skrip efek dasar kartu (Rizki).
- [ ] **Jam 10 – 18 (Eksplorasi & Bounce Back):** Gerak 2D side-scrolling, transisi arena, mekanik *Bounce Back* (Mikael); sprite Bos 1 & latar Sekolah + UI HUD pendulum (Fardan); BGM/SFX dasar + skrip dialog *"Try to Remember"* & AI Bos 1 (Rizki).
- [ ] **Jam 18 – 24 (Milestone Hari 1 — Vertical Slice):** Merge seluruh branch. Uji coba alur penuh dari **Hub → Lapisan Sekolah → Try to Remember → Lawan Bos 1 dengan Bounce Back → Menang & dapat kartu**.

### Hari 2: Ekspansi Konten, *Game Feel*, Balancing & Build (Jam 25 – 48)
- [ ] **Jam 25 – 34 (Ekspansi Konten):** Sprite & arena Bos 2 (*Meja Makan Sunyi*) & Bos 3 (*Cermin Retak*), implementasi penuh 10 kartu emosi, dan fitur *Resilience Echo* saat pemain kalah.
- [ ] **Jam 34 – 40 (Game Feel & Audio):** *Screen shake*, kilatan cahaya pantulan pendulum, partikel kartu, integrasi penuh BGM/SFX, dan menu *Codex Kepingan*.
- [ ] **Jam 40 – 45 (Playtesting, Balancing & Ending):** Playtest penuh bertiga, *balancing* angka kartu/bos, pemasangan *Main Menu* dan adegan *Ending* transisi cahaya hangat.
- [ ] **Jam 45 – 48 (Build & Submit):** Ekspor ke **HTML5 (WebGL)** dan **Windows (`.exe`)**, upload ke **itch.io**, verifikasi di browser, dan tulis deskripsi halaman game untuk juri Hack Club.

> **🚨 Aturan Darurat (Jam ke-36):** Jika jadwal tertinggal pada Jam ke-36, pangkas fitur *Codex Kepingan* dan batasi *deck* menjadi **10 kartu inti** terlebih dahulu. Prioritas mutlak adalah game berjalan lancar dari **Main Menu → 3 Bos → Ending** tanpa *crash*.

---

## 🤝 Panduan Setup & Kolaborasi Git (Godot 4)

### Struktur Folder Proyek
```text
echoes-back/
├── assets/
│   ├── audio/          # BGM & SFX
│   ├── sprites/        # Karakter, Bos, Tileset
│   └── ui/             # Bingkai kartu, ikon, gauge pendulum
├── data/               # File JSON / Resource kartu & dialog
├── scenes/             # File scene Godot (.tscn)
├── scripts/            # File skrip GDScript (.gd)
└── project.godot
```

### Aturan Branch & Anti-Konflik
1. **Gunakan Branch Masing-Masing:**
   * `main` — Branch stabil siap rilis (hanya **Mikael** yang melakukan *merge* ke sini).
   * `mikael-core` — Sistem inti pertarungan, *Emotional Balance*, dan *Bounce Back*.
   * `fardan-art-ui` — Aset visual, animasi, HUD, dan tata letak scene.
   * `rizki-cards-audio` — Data & logika efek kartu, AI bos, dialog, dan audio.
2. **Dilarang mengedit file `.tscn` yang sama secara bersamaan.** Gunakan sistem *scene instancing* (misal `Player.tscn`, `CardUI.tscn`, `Boss1.tscn` dibuat terpisah sebelum dimasukkan ke `BattleArena.tscn`).
3. **Selalu `Pull` / `Update from main` sebelum mulai bekerja**, dan lakukan `Commit + Push` kecil setiap 30–60 menit.
4. **Tutup tab scene di Godot sebelum melakukan `Merge` besar** (atau pilih **Reload** jika muncul peringatan *Scene was modified on disk*).

---

## 📜 Lisensi & Kredit
Dikembangkan secara orisinal oleh **Mikael, Fardan, dan Rizki** untuk event **Hack Club (Tema: Bounce Back)**. Inspirasi genre merujuk pada *Hollow Knight* dan *Slay the Spire*.

> **Catatan build sementara:** `assets/temporary/` berisi background dan tileset pixel-art placeholder untuk prototipe. Ganti dengan artwork final buatan tim sebelum rilis.
