extends Node
## Autoload "GameState": card/boss database, deck, run progress, scene changes.
## Registered in Project Settings > Globals > Autoload.

signal prompt_changed(text: String)
signal toast_requested(text: String)
signal progress_changed

const MENU_SCENE := "res://scenes/main_menu.tscn"
const HUB_SCENE := "res://scenes/hub.tscn"
const BATTLE_SCENE := "res://scenes/battle.tscn"
const ENDING_SCENE := "res://scenes/ending.tscn"
const CARDS_PATH := "res://data/cards.json"
const BOSSES_PATH := "res://data/bosses.json"
const MAX_ECHO := 2  # max stacked "Resilience Echo" energy bonus

var cards: Dictionary = {}       # id -> card dictionary (from cards.json)
var bosses: Dictionary = {}      # id -> boss dictionary (from bosses.json)
var boss_order: Array = []       # boss ids in story order
var starting_deck: Array = []

# --- run progress ---
var deck: Array = []             # card ids (duplicates allowed)
var defeated: Array = []         # boss ids already absorbed
var echo_bonus: int = 0          # Resilience Echo: extra energy on next battle
var current_boss_id: String = "boss_school"
var return_scene: String = HUB_SCENE
var respawn_at_boss: bool = false
var last_portal_x: float = -1.0  # where to place the player in the hub

var _fade_rect: ColorRect
var _changing: bool = false


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _setup_input()
    _load_data()
    _setup_fade()
    reset_run()


# ---------------------------------------------------------------- input map
func _setup_input() -> void:
    # Registered in code so the whole control scheme lives in one place.
    # Change the keys here (or move them into Project Settings > Input Map).
    _add_action("move_left", [KEY_A, KEY_LEFT])
    _add_action("move_right", [KEY_D, KEY_RIGHT])
    _add_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
    _add_action("interact", [KEY_E, KEY_ENTER, KEY_KP_ENTER])


func _add_action(action: StringName, keys: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    for k in keys:
        var ev := InputEventKey.new()
        ev.physical_keycode = k
        InputMap.action_add_event(action, ev)


# ---------------------------------------------------------------- data
func _load_data() -> void:
    var c = _load_json(CARDS_PATH)
    if c is Dictionary:
        for card in c.get("cards", []):
            cards[card["id"]] = card
        starting_deck = c.get("starting_deck", [])
    var b = _load_json(BOSSES_PATH)
    if b is Dictionary:
        for boss in b.get("bosses", []):
            bosses[boss["id"]] = boss
            boss_order.append(boss["id"])


func _load_json(path: String) -> Variant:
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        push_error("Could not open %s" % path)
        return null
    var parsed = JSON.parse_string(f.get_as_text())
    if parsed == null:
        push_error("Invalid JSON in %s" % path)
        return null
    return _intify(parsed)


# JSON numbers are floats; turn whole numbers back into ints.
func _intify(v: Variant) -> Variant:
    match typeof(v):
        TYPE_FLOAT:
            if is_equal_approx(v, roundf(v)):
                return int(v)
            return v
        TYPE_DICTIONARY:
            for k in v.keys():
                v[k] = _intify(v[k])
            return v
        TYPE_ARRAY:
            for i in range(v.size()):
                v[i] = _intify(v[i])
            return v
    return v


func get_card(id: String) -> Dictionary:
    return cards.get(id, {})


func get_boss(id: String) -> Dictionary:
    return bosses.get(id, {})


func build_deck() -> Array:
    var out: Array = []
    for id in deck:
        if cards.has(id):
            out.append(cards[id])
    return out


# ---------------------------------------------------------------- progress
func reset_run() -> void:
    deck = starting_deck.duplicate()
    defeated.clear()
    echo_bonus = 0
    respawn_at_boss = false
    last_portal_x = -1.0
    return_scene = HUB_SCENE
    if not boss_order.is_empty():
        current_boss_id = boss_order[0]
    progress_changed.emit()


func is_defeated(boss_id: String) -> bool:
    return defeated.has(boss_id)


func all_defeated() -> bool:
    return not boss_order.is_empty() and defeated.size() >= boss_order.size()


func start_battle(boss_id: String, from_scene: String) -> void:
    current_boss_id = boss_id
    return_scene = from_scene
    change_scene(BATTLE_SCENE)


## Returns the reward card id ("" if the boss was already absorbed).
func on_battle_won(boss_id: String) -> String:
    var boss: Dictionary = get_boss(boss_id)
    if defeated.has(boss_id):
        return ""
    defeated.append(boss_id)
    var reward: String = String(boss.get("reward_card", ""))
    if reward != "":
        deck.append(reward)
    progress_changed.emit()
    return reward


## Resilience Echo: losing leaves a trace that powers the next attempt.
func on_battle_lost() -> void:
    echo_bonus = mini(echo_bonus + 1, MAX_ECHO)
    respawn_at_boss = true
    progress_changed.emit()


func consume_echo() -> int:
    var e := echo_bonus
    echo_bonus = 0
    progress_changed.emit()
    return e


# ---------------------------------------------------------------- UI helpers
func set_prompt(text: String) -> void:
    prompt_changed.emit(text)


func toast(text: String) -> void:
    toast_requested.emit(text)


# ---------------------------------------------------------------- scenes
func _setup_fade() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    _fade_rect = ColorRect.new()
    _fade_rect.color = Color(0, 0, 0, 0)
    _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(_fade_rect)
    _fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func change_scene(path: String) -> void:
    if _changing:
        return
    _changing = true
    set_prompt("")
    var tw := create_tween()
    tw.tween_property(_fade_rect, "color:a", 1.0, 0.25)
    await tw.finished
    get_tree().paused = false
    get_tree().change_scene_to_file(path)
    await get_tree().process_frame
    await get_tree().process_frame
    var tw2 := create_tween()
    tw2.tween_property(_fade_rect, "color:a", 0.0, 0.3)
    await tw2.finished
    _changing = false
