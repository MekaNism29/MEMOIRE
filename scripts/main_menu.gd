extends Control

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.05, 0.06, 0.09))
	AudioManager.play_bgm("bgm_menu")
	%StartButton.pressed.connect(_on_start)
	%HowToButton.pressed.connect(_on_howto)
	%QuitButton.pressed.connect(_on_quit)
	if OS.has_feature("web"):
		%QuitButton.visible = false
	var tw := create_tween().set_loops()
	tw.tween_property(%Title, "modulate:a", 0.75, 2.0)
	tw.tween_property(%Title, "modulate:a", 1.0, 2.0)


func _on_start() -> void:
	GameState.reset_run()
	AudioManager.play_sfx("ui_click")
	GameState.change_scene(GameState.HUB_SCENE)


func _on_howto() -> void:
	%HowToLabel.visible = not %HowToLabel.visible


func _on_quit() -> void:
	get_tree().quit()
