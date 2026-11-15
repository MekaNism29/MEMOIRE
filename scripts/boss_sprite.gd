extends Control
## Placeholder boss art drawn in code. To use real art, put a PNG at
## res://assets/sprites/<boss_id>.png (e.g. boss_school.png) - it is picked up
## automatically.

var boss_id := "boss_school"
var _tex: Texture2D = null
var _time := 0.0


func set_boss(id: String) -> void:
    boss_id = id
    var path := "res://assets/sprites/%s.png" % id
    _tex = load(path) if ResourceLoader.exists(path) else null
    queue_redraw()


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _draw() -> void:
    if _tex != null:
        draw_texture_rect(_tex, Rect2(Vector2.ZERO, size), false)
        return
    match boss_id:
        "boss_school":
            _draw_board()
        "boss_family":
            _draw_table()
        "boss_childhood":
            _draw_mirror()
        _:
            draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.3, 0.4))


func _draw_board() -> void:
    var w := size.x
    var h := size.y
    draw_rect(Rect2(6, 6, w - 12, h - 26), Color(0.33, 0.26, 0.2))
    draw_rect(Rect2(12, 12, w - 24, h - 38), Color(0.09, 0.15, 0.14))
    draw_rect(Rect2(20, h - 20, w - 40, 8), Color(0.33, 0.26, 0.2))
    var rng := RandomNumberGenerator.new()
    rng.seed = 7
    for i in range(9):
        var a := Vector2(rng.randf_range(20, w - 20), rng.randf_range(18, h - 40))
        draw_line(a, a + Vector2(rng.randf_range(-30, 30), rng.randf_range(-8, 8)), Color(1, 1, 1, 0.25), 2.0)
    for i in range(3):
        var c := Vector2(30 + i * 60, h - 50 - (i % 2) * 22)
        draw_line(c + Vector2(-8, -8), c + Vector2(8, 8), Color(0.9, 0.25, 0.25, 0.8), 3.0)
        draw_line(c + Vector2(-8, 8), c + Vector2(8, -8), Color(0.9, 0.25, 0.25, 0.8), 3.0)
    var bob := sin(_time * 2.0) * 3.0
    draw_circle(Vector2(w * 0.38, h * 0.4 + bob), 9.0, Color(0.9, 0.95, 1.0))
    draw_circle(Vector2(w * 0.62, h * 0.4 + bob), 9.0, Color(0.9, 0.95, 1.0))
    draw_circle(Vector2(w * 0.38, h * 0.4 + bob + 2), 3.5, Color(0.05, 0.05, 0.1))
    draw_circle(Vector2(w * 0.62, h * 0.4 + bob + 2), 3.5, Color(0.05, 0.05, 0.1))


func _draw_table() -> void:
    var w := size.x
    var h := size.y
    var wood := Color(0.35, 0.25, 0.2)
    draw_rect(Rect2(w * 0.08, h * 0.58, w * 0.84, 10), wood)
    draw_rect(Rect2(w * 0.14, h * 0.58, 8, h * 0.38), wood)
    draw_rect(Rect2(w * 0.86 - 8, h * 0.58, 8, h * 0.38), wood)
    for cx in [0.02, 0.9]:
        draw_rect(Rect2(w * cx, h * 0.5, 14, h * 0.46), wood.darkened(0.3))
    draw_circle(Vector2(w * 0.35, h * 0.55), 9.0, Color(0.7, 0.72, 0.8, 0.6))
    draw_circle(Vector2(w * 0.65, h * 0.55), 9.0, Color(0.7, 0.72, 0.8, 0.6))
    var c := Vector2(w * 0.5, h * 0.26)
    draw_arc(c, 24.0, 0.0, TAU, 32, Color(0.85, 0.88, 0.95), 3.0)
    var a := _time * 1.5
    draw_line(c, c + Vector2(sin(a), -cos(a)) * 18.0, Color(1, 1, 1), 2.0)
    draw_line(c, c + Vector2(sin(a / 12.0), -cos(a / 12.0)) * 11.0, Color(1, 1, 1), 3.0)


func _draw_mirror() -> void:
    var w := size.x
    var h := size.y
    var center := Vector2(w * 0.5, h * 0.5)
    var pts := PackedVector2Array()
    for i in range(36):
        var ang := TAU * float(i) / 36.0
        pts.append(center + Vector2(cos(ang) * w * 0.3, sin(ang) * h * 0.46))
    draw_colored_polygon(pts, Color(0.2, 0.22, 0.34))
    draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0.8, 0.7, 1.0), 4.0)
    # small figure hiding in the corner
    draw_circle(center + Vector2(-w * 0.1, h * 0.15), 8.0, Color(0.05, 0.05, 0.1))
    draw_rect(Rect2(center.x - w * 0.1 - 9.0, center.y + h * 0.15 + 6.0, 18, 24), Color(0.05, 0.05, 0.1))
    draw_circle(center + Vector2(-w * 0.1 + 3.0, h * 0.15 - 1.0), 1.8, Color(1, 1, 1, 0.6 + 0.4 * sin(_time * 3.0)))
    # cracks
    var cr := Color(1, 1, 1, 0.75)
    draw_line(center + Vector2(0, -h * 0.46), center + Vector2(14, -h * 0.15), cr, 2.0)
    draw_line(center + Vector2(14, -h * 0.15), center + Vector2(-10, h * 0.1), cr, 2.0)
    draw_line(center + Vector2(-10, h * 0.1), center + Vector2(20, h * 0.44), cr, 2.0)
    draw_line(center + Vector2(14, -h * 0.15), center + Vector2(w * 0.25, -h * 0.05), cr, 2.0)
