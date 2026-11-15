extends Interactable
## A door between the hub and a memory layer.
## target_scene: scene to load. required_boss: boss id that must already be
## absorbed before this door opens (leave empty for always-open).

const SIZE := Vector2(120, 200)

@export_file("*.tscn") var target_scene := ""
@export var required_boss := ""
@export var door_name := "Pintu"
@export var door_color := Color(0.6, 0.7, 1.0)

var _t := 0.0


func is_locked() -> bool:
    return required_boss != "" and not GameState.is_defeated(required_boss)


func get_prompt() -> String:
    if is_locked():
        return "Terkunci - serap kenangan sebelumnya terlebih dahulu."
    return "[E] Masuk: %s" % door_name


func interact(_player: Node) -> void:
    if is_locked():
        return
    if target_scene != GameState.HUB_SCENE:
        GameState.last_portal_x = global_position.x
    AudioManager.play_sfx("ui_click")
    GameState.change_scene(target_scene)


func _process(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    var locked := is_locked()
    var col := door_color
    if locked:
        col = Color(0.35, 0.37, 0.45)
    var pulse := 0.5 + 0.5 * sin(_t * 2.0)
    var r := Rect2(-SIZE.x / 2.0, -SIZE.y / 2.0, SIZE.x, SIZE.y)
    draw_rect(r, Color(col.r * 0.25, col.g * 0.25, col.b * 0.25, 0.9))
    if not locked:
        draw_rect(r.grow(8.0), Color(col.r, col.g, col.b, 0.06 + 0.08 * pulse))
    draw_rect(r, col, false, 3.0)
    draw_arc(Vector2(0, -SIZE.y / 2.0), SIZE.x / 2.0, PI, TAU, 24, col, 3.0)
    var font := ThemeDB.get_project_theme().default_font
    draw_string(font, Vector2(-110, -SIZE.y / 2.0 - 40.0), door_name,
        HORIZONTAL_ALIGNMENT_CENTER, 220, 16, Color(col.r, col.g, col.b, 0.95))
