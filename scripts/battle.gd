extends Control
## Turn-based card battle UI. All rules live in battle_state.gd.
## Flow: card click -> play_card; BOUNCE BACK button -> pick a card to sacrifice;
## "Akhiri Giliran" -> boss acts -> next turn.

const CARD_UI := preload("res://scenes/card_ui.tscn")
const LOG_LINES := 2

var state: BattleState
var boss_data: Dictionary = {}
var selecting_sacrifice := false
var busy := false

var _log: Array = []
var _last_boss_hp := 0
var _result_shown := false

@onready var boss_sprite = %BossSprite
@onready var boss_name: Label = %BossName
@onready var boss_hp_bar: ProgressBar = %BossHP
@onready var boss_hp_label: Label = %BossHPLabel
@onready var intent_label: Label = %Intent
@onready var gauge = %Gauge
@onready var turn_label: Label = %TurnLabel
@onready var energy_label: Label = %EnergyLabel
@onready var shield_label: Label = %ShieldLabel
@onready var piles_label: Label = %PilesLabel
@onready var log_label: Label = %LogLabel
@onready var hand_box: HBoxContainer = %Hand
@onready var bounce_button: Button = %BounceButton
@onready var end_turn_button: Button = %EndTurnButton
@onready var result: Control = %Result
@onready var result_title: Label = %ResultTitle
@onready var result_text: Label = %ResultText
@onready var result_button: Button = %ResultButton


func _ready() -> void:
    boss_data = GameState.get_boss(GameState.current_boss_id)
    if boss_data.is_empty():
        push_error("Unknown boss id: %s" % GameState.current_boss_id)
        return
    state = BattleState.new()
    state.message.connect(_on_message)
    state.balance_changed.connect(_on_balance_changed)
    state.bounce_back_fired.connect(_on_bounce_fired)
    state.card_played.connect(_on_card_played)

    boss_sprite.set_boss(String(boss_data["id"]))
    boss_name.text = String(boss_data["name"])
    bounce_button.pressed.connect(_on_bounce_pressed)
    end_turn_button.pressed.connect(_on_end_turn_pressed)
    result_button.pressed.connect(_on_result_button_pressed)
    result.visible = false
    gauge.set_balance(0, true)

    _last_boss_hp = int(boss_data["hp"])
    AudioManager.play_bgm("bgm_battle")
    state.start(boss_data, GameState.build_deck(), GameState.consume_echo())
    _refresh()


# ------------------------------------------------------------ refresh
func _refresh() -> void:
    boss_hp_bar.max_value = state.boss_max_hp
    boss_hp_bar.value = state.boss_hp
    boss_hp_label.text = "Trauma Shield  %d / %d" % [state.boss_hp, state.boss_max_hp]
    intent_label.text = "Niat bos: " + state.intent_text()
    turn_label.text = "Giliran %d" % state.turn
    energy_label.text = "Energi %d" % state.energy
    shield_label.text = "Shield %d" % state.shield
    piles_label.text = "Dek %d / Buang %d" % [state.draw_pile.size(), state.discard_pile.size()]

    var start := maxi(0, _log.size() - LOG_LINES)
    var text := ""
    for i in range(start, _log.size()):
        text += String(_log[i]) + "\n"
    log_label.text = text.strip_edges()

    if state.boss_hp < _last_boss_hp:
        _hit_boss()
    _last_boss_hp = state.boss_hp

    # hand
    for c in hand_box.get_children():
        hand_box.remove_child(c)
        c.queue_free()
    var n := state.hand.size()
    var w := clampi(int(1180.0 / float(maxi(n, 1))) - 8, 96, 150)
    for i in range(n):
        var card_ui = CARD_UI.instantiate()
        hand_box.add_child(card_ui)
        card_ui.custom_minimum_size = Vector2(w, 214)
        var playable := (not busy) and state.play_block_reason(i) == ""
        card_ui.setup(state.hand[i], playable, selecting_sacrifice)
        card_ui.pressed.connect(_on_card_pressed.bind(i))

    # buttons
    end_turn_button.disabled = busy or state.finished
    if selecting_sacrifice:
        bounce_button.text = "Pilih kartu untuk dikorbankan (klik untuk batal)"
        bounce_button.disabled = false
        bounce_button.modulate = Color(1.0, 0.8, 0.4)
    else:
        bounce_button.text = "BOUNCE BACK"
        var can := (not busy) and state.bounce_available()
        bounce_button.disabled = not can
        bounce_button.modulate = Color(1.0, 0.8, 0.4) if can else Color(1, 1, 1)


func _add_log(text: String) -> void:
    _log.append(text)


# ------------------------------------------------------------ signals from state
func _on_message(text: String) -> void:
    _add_log(text)


func _on_balance_changed(_old: int, new_value: int) -> void:
    gauge.set_balance(new_value)


func _on_bounce_fired(_damage: int) -> void:
    AudioManager.play_sfx("bounce_back")
    gauge.play_flash()
    _shake(14.0)


func _on_card_played(_card: Dictionary) -> void:
    AudioManager.play_sfx("card_play")


# ------------------------------------------------------------ input
func _on_card_pressed(i: int) -> void:
    if busy or state.finished:
        return
    if selecting_sacrifice:
        selecting_sacrifice = false
        state.bounce_back(i)
        _refresh()
        _check_finished()
        return
    var reason := state.play_block_reason(i)
    if reason != "":
        _add_log(reason)
        _refresh()
        return
    state.play_card(i)
    _refresh()
    _check_finished()


func _on_bounce_pressed() -> void:
    if busy or state.finished:
        return
    if selecting_sacrifice:
        selecting_sacrifice = false
        _refresh()
        return
    if not state.bounce_available():
        return
    selecting_sacrifice = true
    _add_log("Pilih 1 kartu di tangan untuk dikorbankan.")
    _refresh()


func _on_end_turn_pressed() -> void:
    if busy or state.finished:
        return
    busy = true
    selecting_sacrifice = false
    state.end_player_turn()
    _refresh()
    await get_tree().create_timer(0.5).timeout
    state.enemy_turn()
    AudioManager.play_sfx("hit")
    _shake(8.0)
    _refresh()
    if state.finished:
        busy = false
        _refresh()
        _check_finished()
        return
    await get_tree().create_timer(0.7).timeout
    state.start_player_turn()
    busy = false
    _refresh()


# ------------------------------------------------------------ result
func _check_finished() -> void:
    if state.finished:
        _show_result()


func _show_result() -> void:
    if _result_shown:
        return
    _result_shown = true
    await get_tree().create_timer(0.8).timeout
    result.visible = true
    if state.won:
        AudioManager.play_sfx("boss_defeated")
        var reward: String = GameState.on_battle_won(String(boss_data["id"]))
        result_title.text = "Kenangan diserap"
        var txt := "%s melebur dan menjadi bagian dirimu." % boss_data["name"]
        if reward != "":
            var card: Dictionary = GameState.get_card(reward)
            txt += "\n\nKartu baru: %s\n%s" % [card.get("name", reward), card.get("desc", "")]
        result_text.text = txt
        result_button.text = "Kembali ke Alam Bawah Sadar"
    else:
        GameState.on_battle_lost()
        result_title.text = "Terpantul jatuh"
        result_text.text = "Pendulum menyentuh %+d dan tak sempat kembali.\n\nKekalahan bukan akhir. Resilience Echo: +%d Energi di percobaan berikutnya." % [state.balance, GameState.echo_bonus]
        result_button.text = "Bangkit kembali"


func _on_result_button_pressed() -> void:
    if state.won:
        GameState.change_scene(GameState.HUB_SCENE)
    else:
        GameState.change_scene(GameState.return_scene)


# ------------------------------------------------------------ juice
func _hit_boss() -> void:
    var tw := create_tween()
    boss_sprite.modulate = Color(1.0, 0.35, 0.35)
    tw.tween_property(boss_sprite, "modulate", Color(1, 1, 1), 0.3)
    _shake(5.0)


func _shake(amount: float) -> void:
    var tw := create_tween()
    for i in range(6):
        tw.tween_property(self, "position",
            Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), 0.04)
    tw.tween_property(self, "position", Vector2.ZERO, 0.05)
