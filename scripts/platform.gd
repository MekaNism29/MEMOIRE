@tool
extends StaticBody2D
## Simple resizable platform using the temporary Echoes Back pixel tiles.

const TILESET := preload("res://assets/temporary/echoes_tileset_temp.png")
const TILE := 32

@export var size := Vector2(256, 32):
    set(v):
        size = v
        _rebuild()
@export var color := Color(1, 1, 1, 1):
    set(v):
        color = v
        queue_redraw()
@export var one_way := false:
    set(v):
        one_way = v
        _rebuild()

func _ready() -> void:
    _rebuild()

func _rebuild() -> void:
    var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
    if cs != null:
        var rect := RectangleShape2D.new()
        rect.size = size
        cs.shape = rect
        cs.position = size / 2.0
        cs.one_way_collision = one_way
    queue_redraw()

func _draw() -> void:
    var cols := ceili(size.x / float(TILE))
    var rows := ceili(size.y / float(TILE))
    for y in range(rows):
        for x in range(cols):
            var w := minf(TILE, size.x - x * TILE)
            var h := minf(TILE, size.y - y * TILE)
            var source := Rect2(0, 0, TILE, TILE) if y == 0 else Rect2(0, 32, TILE, TILE)
            if x % 5 == 4 and y == 0:
                source = Rect2(32, 0, TILE, TILE)
            draw_texture_rect_region(TILESET, Rect2(x * TILE, y * TILE, w, h), source, color.lightened(0.65))
