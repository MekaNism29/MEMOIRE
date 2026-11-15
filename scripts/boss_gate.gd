extends Interactable
## The doorway to a Trauma boss. [E] opens the "Try to Remember" flashback,
## which then leads to the turn-based battle.

const OVERLAY := preload("res://scenes/remember_overlay.tscn")
const SIZE := Vector2(160, 220)

@export var boss_id := "boss_school"

var _t := 0.0


func get_prompt() -> String:
	if GameState.is_defeated(boss_id):
		return "Kenangan ini sudah kamu serap."
	return "[E] Try to Remember"


func interact(_player: Node) -> void:
	if GameState.is_defeated(boss_id):
		return
	var boss: Dictionary = GameState.get_boss(boss_id)
	var overlay = OVERLAY.instantiate()
	get_tree().current_scene.add_child(overlay)
	overlay.setup(boss)
	overlay.confirmed.connect(_on_confirmed)
	get_tree().paused = true


func _on_confirmed() -> void:
	GameState.start_battle(boss_id, get_tree().current_scene.scene_file_path)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var boss: Dictionary = GameState.get_boss(boss_id)
	var g: Array = boss.get("glow", [0.6, 0.7, 1.0])
	var col := Color(float(g[0]), float(g[1]), float(g[2]))
	var done := GameState.is_defeated(boss_id)
	if done:
		col = Color(0.4, 0.42, 0.5)
	var pulse := 0.5 + 0.5 * sin(_t * 2.5)
	var r := Rect2(-SIZE.x / 2.0, -SIZE.y / 2.0, SIZE.x, SIZE.y)
	draw_rect(r, Color(0.02, 0.02, 0.05, 0.9))
	if not done:
		draw_rect(r.grow(10.0), Color(col.r, col.g, col.b, 0.08 + 0.1 * pulse))
		# swirling fragments inside the doorway
		for i in range(7):
			var a := _t * 0.8 + float(i) * 0.9
			var p := Vector2(sin(a * 1.3) * 50.0, cos(a) * 80.0)
			draw_circle(p, 5.0 + 3.0 * sin(a * 2.0), Color(col.r, col.g, col.b, 0.5))
	draw_rect(r, col, false, 4.0)
