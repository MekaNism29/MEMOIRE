extends Button
## One card in the player's hand. Instanced by battle.gd.

const BG := Color(0.12, 0.13, 0.18)
const BORDER := Color(0.35, 0.4, 0.5)


func setup(entry: Dictionary, playable: bool, sacrifice_mode: bool) -> void:
    var card: Dictionary = entry["card"]
    var locked: bool = entry["locked"]
    var border := BORDER
    if locked:
        border = Color(0.85, 0.2, 0.2)
    if sacrifice_mode:
        border = Color(1.0, 0.55, 0.15)

    %NameLabel.text = String(card["name"])
    %CostLabel.text = str(entry["cost"])
    %DescLabel.text = ("[SILENCE] " if locked else "") + String(card["desc"])
    modulate = Color(1, 1, 1, 1) if (playable or sacrifice_mode) else Color(1, 1, 1, 0.55)

    add_theme_stylebox_override("normal", _box(BG, border, 1))
    add_theme_stylebox_override("hover", _box(BG.lightened(0.1), border.lightened(0.3), 2))
    add_theme_stylebox_override("pressed", _box(BG.darkened(0.1), border, 2))
    add_theme_stylebox_override("focus", _box(BG, border, 1))
    add_theme_stylebox_override("disabled", _box(BG.darkened(0.3), border.darkened(0.4), 1))


func _box(bg: Color, border: Color, width: int) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg
    sb.border_color = border
    sb.set_border_width_all(width)
    sb.set_corner_radius_all(3)
    return sb
