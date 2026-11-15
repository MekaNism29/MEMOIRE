extends CanvasLayer
## Overlay for exploration scenes: info line, interaction prompt, banners.

var _banner_tween: Tween


func _ready() -> void:
    GameState.prompt_changed.connect(_on_prompt_changed)
    GameState.toast_requested.connect(_on_toast)
    GameState.progress_changed.connect(_update_info)
    %Prompt.text = ""
    %Banner.modulate.a = 0.0
    _update_info()


func _update_info() -> void:
    %Info.text = "Kenangan: %d/%d   |   A/D bergerak   Space lompat   E interaksi" % [
        GameState.defeated.size(), GameState.boss_order.size()]


func _on_prompt_changed(text: String) -> void:
    %Prompt.text = text


func _on_toast(text: String) -> void:
    show_banner(text, 1.8)


func show_banner(text: String, duration: float = 2.0) -> void:
    %Banner.text = text
    if _banner_tween != null:
        _banner_tween.kill()
    %Banner.modulate.a = 0.0
    _banner_tween = create_tween()
    _banner_tween.tween_property(%Banner, "modulate:a", 1.0, 0.4)
    _banner_tween.tween_interval(duration)
    _banner_tween.tween_property(%Banner, "modulate:a", 0.0, 0.8)
