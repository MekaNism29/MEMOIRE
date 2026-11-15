# MEMOIRE - Catatan Pengembangan

Game 2D side-scrolling + battle kartu, dibuat di Godot 4.7 (renderer GL Compatibility, jadi bisa di-export ke Web/itch.io).
Cara jalanin: buka Godot, Import, pilih `project.godot`, tekan F5.

## Kenapa bikin game ini

Game ini terinspirasi dari Hollow Knight dan Slay the Spire. Dari Hollow Knight, kita suka bagian jalan-jalan dan lompat-lompat menjelajahi dunianya. Tapi kalau cuma itu, gamenya terasa cuma cerita yang jalan terus.
 Makanya kita padukan dengan pertarungan kartu ala Slay the Spire, jadi tiap battle kita harus mikir dulu: kartu mana yang dipakai, dan gimana caranya biar menang.
 Dengan begitu game-nya lebih seru, nggak cuma jalan dan lompat, tapi ada tantangan yang bikin pemain harus berpikir. 

## Alur game

`main_menu` -> `hub` (Dasar Alam Bawah Sadar) -> portal -> `level_school` / `level_family` / `level_childhood`
-> gerbang bos (tekan E) -> `battle` -> balik ke hub.
Setelah 3 bos kalah, muncul cahaya di hub -> `ending`.
Lapisannya kebuka berurutan: Sekolah, Keluarga, Masa Kecil.

## File penting

| Apa | File |
| --- | --- |
| Data 10 kartu (angka, cost, teks) | `data/cards.json` |
| Data 3 bos (HP, teks flashback, pola, hadiah) | `data/bosses.json` |
| Aturan battle: energi, Balance, Bounce Back, efek kartu, AI bos | `scripts/battle_state.gd` |
| Tampilan battle | `scenes/battle.tscn` + `scripts/battle.gd` |
| Gambar pendulum | `scripts/pendulum_gauge.gd` |
| Gerak pemain (kecepatan, lompat, coyote time) | `scripts/player.gd` (konstanta di atas) |
| Dek, progres, pindah scene, tombol | `scripts/game_state.gd` (autoload) |
| Audio | `scripts/audio_manager.gd` (autoload) |
| Level | `scenes/level_*.tscn`, `scenes/hub.tscn` |

## Aturan battle (versi yang jalan sekarang)

- Tiap giliran: energi 3, tarik 3 kartu, Perisai di-reset ke 0.
- **Balance** itu pendulum dari -10 sampai +10. Kalah kalau Balance masih di -10 atau +10 waktu giliran bos selesai.
- **Bounce Back** bisa dipakai saat Balance di -9 sampai -7. Korbankan 1 kartu, Balance lompat ke +1, bos kena damage sebesar jarak yang ditempuh (dari -8 ke +1 = 9 damage). Di -10 sudah nggak bisa.
- **Perisai** menyerap poin dorongan bos sebelum Balance bergeser.
- Damage kartu langsung kena HP bos, nggak ada pengurang.
- **Kecewa** mengurangi dorongan bos berikutnya 3 poin.
- **Kepingan Tekad**: tiap poin Balance negatif jadi +1 Perisai.
- **Kepingan Hangat**: Balance langsung ke 0 dan tarik 2 kartu.
- **Kepingan Terima**: 12 damage dan Balance langsung ke 0.
- **Resilience Echo**: tiap kalah, giliran pertama battle berikutnya dapat +1 Energi (maksimal numpuk +2).
- Dek awal 10 kartu: 2 Marah, 2 Tenang, 2 Rindu, Takut, Bangga, Kecewa, Lega. Kartu baru cuma dari hadiah bos.

### Pola bos

| Bos | HP | Pola |
| --- | --- | --- |
| Bayangan Papan Tulis | 22 | `constant_shift`: dorong Balance -2 tiap giliran |
| Meja Makan Sunyi | 27 | `alternating_shift`: giliran ganjil -1, genap +1 |
| Cermin Retak | 32 | `mirror_push`: dorong +2, ditambah damage kartu terakhirmu dibagi 6 (dibulatkan ke bawah) |

## Cara ngedit

**Ubah kartu** - edit `data/cards.json`. Key efek yang didukung:
`damage`, `damage_if_negative`, `shield`, `shield_from_negative`, `draw`, `energy_gain`,
`balance_shift` (negatif = ke kiri), `balance_pull` (tarik ke 0), `set_balance_zero`,
`boss_attack_reduction`, `double_next`, `lock_balance`, `no_extra_draw`, `discard_random`,
`next_turn_energy_penalty`, `clear_debuffs`, `returns_if_negative`, `requires_balance_max`,
`passive_resist_left`. Efek baru = tambah satu `if` di `_apply_card()` di `battle_state.gd`.

Catatan: beberapa efek di atas (`double_next`, `lock_balance`, `no_extra_draw`, `next_turn_energy_penalty`, `passive_resist_left`, dll.) sudah ada di kode tapi belum dipakai kartu mana pun. Itu sisa fitur yang sempat direncanakan.

**Ubah bos** - edit `data/bosses.json`. Pola baru = tambah cabang di `_boss_shift_for_turn()` dan `intent_text()`.

**Angka inti** (energi 3, tangan 3, zona bounce -9 sampai -7, mendarat di +1) - konstanta di atas `battle_state.gd`.

**Ubah level** - buka scene level. Platform itu instance `platform.tscn`, tinggal geser dan ubah `size` / `color` di Inspector. Marker `Checkpoints` = tempat respawn setelah jatuh ke jurang.

**Tambah art** (kebaca otomatis, kode nggak perlu diubah):
- `assets/sprites/player.png` (kaki di tengah bawah)
- `assets/sprites/boss_school.png`, `boss_family.png`, `boss_childhood.png`

**Tambah audio** (kebaca otomatis): taruh di `assets/audio/` dengan nama
`jump, pickup, ui_click, card_play, hit, bounce_back, boss_defeated` (efek suara) dan
`bgm_menu, bgm_hub, bgm_school, bgm_family, bgm_childhood, bgm_battle, bgm_ending` (musik, aktifkan Loop di Import).

**Tombol** - `GameState._setup_input()`.

## Belum sempat dibuat

- Menu Codex Kepingan
- Save/load (progres hilang kalau game ditutup)
- Art, audio, dan animasi final (sementara masih pakai aset di `assets/temporary/`)

## Yang susah / yang kita pelajari

Yang paling susah buat kita adalah ini pertama kalinya kita bikin game. Apalagi ide game-nya langsung diambil dari dua game terkenal, Hollow Knight dan Slay the Spire.
 Kita harus ikir gimana caranya menggabungkan keduanya jadi satu game, karena masing-masing punya karakteristik sendiri: yang satu action platformer yang jalan dan lompat, yang satunya battle kartu yang main giliran.
## Export

Project > Export > tambah preset **Web** dan **Windows Desktop** (download export templates dulu).
Untuk Web: zip folder hasil export lalu upload ke itch.io.

## Kalau error

- `Identifier not found: GameState/AudioManager` -> cek Project Settings > Globals > Autoload, dua-duanya harus ada.
- `Could not find type "LevelBase" / "BattleState" / "Interactable"` -> tunggu Godot selesai scan pertama, atau Project > Reload Current Project.
- Scene "was modified on disk" -> pilih Reload.

## Aset sementara

- `assets/temporary/echoes_background_temp.png`: background berulang.
- `assets/temporary/echoes_tileset_temp.png`: atlas 2x2 yang dipakai `scripts/platform.gd`.
Dua-duanya masih placeholder dan rencananya diganti.
