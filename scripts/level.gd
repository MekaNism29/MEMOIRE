class_name LevelBase
extends Node2D
## Shared logic for the hub and three memory layers.

const BACKGROUND := preload("res://assets/temporary/echoes_background_temp.png")

@export var layer_id := "school"
@export var layer_title := "LAPISAN SEKOLAH"
@export var world_width := 2300
@export var kill_y := 900.0
@export var bg_color := Color(0.05, 0.06, 0.09)
@export var decor_color := Color(0.1, 0.12, 0.18)
## Drag your own background image here (Inspector). Empty = old temporary background.
@export var background: Texture2D

@onready var player: CharacterBody2D = $Player
@onready var spawn: Marker2D = $Spawn

func _ready() -> void:
    RenderingServer.set_default_clear_color(bg_color)
    var cam: Camera2D = player.get_node("Camera2D")
    cam.limit_left = 0
    cam.limit_right = world_width
    cam.limit_top = 0
    cam.limit_bottom = 720
    player.global_position = spawn.global_position
    if GameState.respawn_at_boss and has_node("BossSpawn"):
        player.global_position = $BossSpawn.global_position
    GameState.respawn_at_boss = false
    cam.reset_smoothing()
    GameState.set_prompt("")
    AudioManager.play_bgm("bgm_" + layer_id)
    if has_node("HUD"):
        $HUD.show_banner(layer_title, 2.5)
    queue_redraw()

func _physics_process(_delta: float) -> void:
    if player.global_position.y > kill_y:
        player.global_position = _checkpoint_for(player.global_position.x)
        player.velocity = Vector2.ZERO

func _checkpoint_for(x: float) -> Vector2:
    var best: Vector2 = spawn.global_position
    var best_x := -INF
    if has_node("Checkpoints"):
        for c in $Checkpoints.get_children():
            if c is Marker2D:
                var cx: float = c.global_position.x
                if cx <= x and cx > best_x:
                    best = c.global_position
                    best_x = cx
    return best

func _draw() -> void:
    var tint := Color(0.72, 0.82, 1.0, 1.0)
    match layer_id:
        "family": tint = Color(1.0, 0.78, 0.62, 1.0)
        "childhood": tint = Color(0.83, 0.72, 1.0, 1.0)
        "hub": tint = Color(0.76, 0.82, 0.94, 1.0)
    var tex: Texture2D = BACKGROUND
    if background != null:
        tex = background
        tint = Color(1, 1, 1, 1)
    # scale to screen height (720), keep the aspect ratio, repeat to the right.
    # every 2nd tile is mirrored so the seam between tiles is invisible.
    var tile_w: float = tex.get_width() * 720.0 / tex.get_height()
    var x := 0.0
    var i := 0
    while x < world_width:
        if background != null and i % 2 == 1:
            draw_set_transform(Vector2(x + tile_w, 0), 0.0, Vector2(-1, 1))
            draw_texture_rect(tex, Rect2(0, 0, tile_w, 720), false, tint)
            draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        else:
            draw_texture_rect(tex, Rect2(x, 0, tile_w + 1.0, 720), false, tint)
        x += tile_w
        i += 1
    # A restrained dark wash keeps the player and platforms readable.
    draw_rect(Rect2(0, 0, world_width, 720), Color(0.025, 0.035, 0.06, 0.20), true)
