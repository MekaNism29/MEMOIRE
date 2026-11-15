extends Control
## The Emotional Balance pendulum (-10 .. +10). Pure drawing; battle.gd feeds it values.

var value := 0.0     # animated position
var target := 0      # real balance
var flash := 0.0
var _time := 0.0
var _tween: Tween


func set_balance(v: int, instant: bool = false) -> void:
    target = v
    if _tween != null:
        _tween.kill()
    if instant:
        value = float(v)
        queue_redraw()
        return
    _tween = create_tween()
    _tween.tween_property(self, "value", float(v), 0.35) \
        .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func play_flash() -> void:
    flash = 1.0
    var tw := create_tween()
    tw.tween_property(self, "flash", 0.0, 0.5)


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _cell_color(v: int) -> Color:
    if v == 0:
        return Color(0.55, 0.6, 0.7)
    if v < 0:
        return Color(0.15, 0.2, 0.33)
    return Color(0.4, 0.2, 0.22)


func _draw() -> void:
    var w := size.x
    var h := size.y
    var font := get_theme_default_font()
    var cell_w := minf(54.0, (w - 40.0) / 21.0)
    var total := cell_w * 21.0
    var x0 := (w - total) / 2.0
    var bar_h := 38.0
    var bar_y := h - bar_h - 6.0
    var in_zone := target >= -9 and target <= -7

    for i in range(21):
        var v := i - 10
        var col := _cell_color(v)
        if v >= -9 and v <= -7:
            col = col.lerp(Color(1.0, 0.6, 0.15), 0.45 if in_zone else 0.25)
        var r := Rect2(x0 + i * cell_w + 1.0, bar_y, cell_w - 2.0, bar_h)
        draw_rect(r, col)
        if absi(v) == 10:
            draw_rect(r, Color(0.95, 0.25, 0.25), false, 2.0)
        draw_string(font, Vector2(x0 + i * cell_w, bar_y + bar_h * 0.65), str(v),
            HORIZONTAL_ALIGNMENT_CENTER, cell_w, 15, Color(1, 1, 1, 0.9))

    # pendulum: pivot at top-center, weight sits on the current cell
    var wx := x0 + (value + 10.0 + 0.5) * cell_w
    var pivot := Vector2(w * 0.5, 4.0)
    var weight := Vector2(wx, bar_y - 18.0)
    draw_line(pivot, weight, Color(0.8, 0.85, 1.0, 0.5), 2.0)
    draw_circle(weight, 11.0, Color(1.0, 0.85, 0.45))

    draw_string(font, Vector2(x0, 22), "TERPURUK / APATIS", HORIZONTAL_ALIGNMENT_LEFT,
        -1, 14, Color(0.5, 0.65, 1.0, 0.9))
    draw_string(font, Vector2(x0, 22), "OVERWHELMED / MELEDAK", HORIZONTAL_ALIGNMENT_RIGHT,
        total, 14, Color(1.0, 0.5, 0.45, 0.9))
    if in_zone:
        draw_string(font, Vector2(x0, 42), "BOUNCE BACK TERSEDIA!", HORIZONTAL_ALIGNMENT_LEFT,
            -1, 15, Color(1.0, 0.7, 0.25))
