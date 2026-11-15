extends Node
## Autoload "AudioManager". Drop audio files into res://assets/audio/ using the
## names below (.ogg / .wav / .mp3) and they play automatically. Missing files
## are silently skipped, so the game runs fine without any audio.
##
## SFX names: jump, pickup, ui_click, card_play, hit, bounce_back, boss_defeated
## BGM names: bgm_menu, bgm_hub, bgm_school, bgm_family, bgm_childhood,
##            bgm_battle, bgm_ending  (enable "Loop" in the Import dock for BGM)

const AUDIO_DIR := "res://assets/audio/"
const EXTENSIONS := ["ogg", "wav", "mp3"]

var _bgm: AudioStreamPlayer
var _sfx_players: Array = []
var _current_bgm := ""
var _cache: Dictionary = {}


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _bgm = AudioStreamPlayer.new()
    add_child(_bgm)
    for i in range(6):
        var p := AudioStreamPlayer.new()
        add_child(p)
        _sfx_players.append(p)


func play_sfx(sfx_name: String) -> void:
    var stream = _find(sfx_name)
    if stream == null:
        return
    for p in _sfx_players:
        if not p.playing:
            p.stream = stream
            p.play()
            return


func play_bgm(bgm_name: String) -> void:
    if bgm_name == _current_bgm:
        return
    _current_bgm = bgm_name
    var stream = _find(bgm_name)
    if stream == null:
        _bgm.stop()
        return
    _bgm.stream = stream
    _bgm.play()


func _find(audio_name: String) -> Variant:
    if _cache.has(audio_name):
        return _cache[audio_name]
    var found = null
    for ext in EXTENSIONS:
        var path := "%s%s.%s" % [AUDIO_DIR, audio_name, ext]
        if ResourceLoader.exists(path):
            found = load(path)
            break
    _cache[audio_name] = found
    return found
