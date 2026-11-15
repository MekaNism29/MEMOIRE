extends LevelBase
## The hub: "Dasar Alam Bawah Sadar". The palette warms as traumas are absorbed.

func _ready() -> void:
    super._ready()
    var done := GameState.defeated.size()
    var total := maxi(1, GameState.boss_order.size())
    var t := float(done) / float(total)
    var cold := Color(0.78, 0.84, 1.0)
    var warm := Color(1.0, 0.9, 0.72)
    $CanvasModulate.color = cold.lerp(warm, t)
    RenderingServer.set_default_clear_color(bg_color.lerp(Color(0.22, 0.15, 0.09), t))

    if GameState.last_portal_x >= 0.0:
        player.global_position = Vector2(GameState.last_portal_x, spawn.global_position.y)
        var cam: Camera2D = player.get_node("Camera2D")
        cam.reset_smoothing()

    var complete := GameState.all_defeated()
    var wake = $Interactables/WakeLight
    wake.visible = complete
    wake.monitoring = complete
    if complete:
        $HUD.show_banner("Retakan cahaya muncul di langit-langit...", 3.5)
    queue_redraw()


func _draw() -> void:
    super._draw()
    var done := GameState.defeated.size()
    # crack in the ceiling
    var crack := PackedVector2Array([
        Vector2(900, 0), Vector2(940, 50), Vector2(905, 95), Vector2(960, 150),
        Vector2(930, 200), Vector2(985, 250),
    ])
    draw_polyline(crack, Color(0.85, 0.9, 1.0, 0.5 + 0.15 * float(done)), 3.0)
    for i in range(done):
        var bx := 930.0 + float(i - 1) * 80.0
        draw_colored_polygon(PackedVector2Array([
            Vector2(bx - 10.0, 120), Vector2(bx + 10.0, 120),
            Vector2(bx + 90.0, 640), Vector2(bx - 90.0, 640),
        ]), Color(1.0, 0.85, 0.5, 0.07))
