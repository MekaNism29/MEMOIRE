extends Interactable
## Appears in the hub after all three traumas are absorbed. Triggers the ending.

var _t := 0.0


func get_prompt() -> String:
    return "[E] Bangun"


func interact(_player: Node) -> void:
    GameState.change_scene(GameState.ENDING_SCENE)


func _process(delta: float) -> void:
    _t += delta
    queue_redraw()


func _draw() -> void:
    var pulse := 0.5 + 0.5 * sin(_t * 1.6)
    draw_colored_polygon(PackedVector2Array([
        Vector2(-26, -520), Vector2(26, -520), Vector2(110, 120), Vector2(-110, 120),
    ]), Color(1.0, 0.85, 0.5, 0.10 + 0.08 * pulse))
    draw_colored_polygon(PackedVector2Array([
        Vector2(-10, -520), Vector2(10, -520), Vector2(46, 120), Vector2(-46, 120),
    ]), Color(1.0, 0.95, 0.75, 0.16 + 0.1 * pulse))
