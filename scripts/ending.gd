extends Control
## Ending: the palette shifts from cold monochrome to warm gold.

const LINES := [
	"Kamu melihat sebuah cahaya.",
	"Semuanya menjadi kepingan",
	"Kamu bangkit, dan memantul kembali",
	"Udara hangat menyentuh. dan cahaya muncul.",
	"Kamu terbangun.",
]

func _ready() -> void:
	AudioManager.play_bgm("bgm_ending")
	%MenuButton.pressed.connect(_on_menu)
	_play()


func _play() -> void:
	var text: Label = %Text
	text.modulate.a = 0.0

	var color_tween := create_tween()
	color_tween.tween_method(_set_progress, 0.0, 1.0, 22.0)

	for line in LINES:
		text.text = line
		var tw := create_tween()
		tw.tween_property(text, "modulate:a", 1.0, 1.2)
		tw.tween_interval(2.6)
		tw.tween_property(text, "modulate:a", 0.0, 0.9)
		await tw.finished

	text.text = ""
	%Title.visible = true
	%Title.modulate.a = 0.0
	var tw2 := create_tween()
	tw2.tween_property(%Title, "modulate:a", 1.0, 1.5)
	await tw2.finished
	%MenuButton.visible = true


func _set_progress(t: float) -> void:
	var cold := Color(0.05, 0.06, 0.09)
	var warm := Color(0.96, 0.76, 0.42)
	var text_cold := Color(0.88, 0.91, 0.98)
	var text_warm := Color(0.25, 0.14, 0.05)
	%Bg.color = cold.lerp(warm, t)
	%Text.add_theme_color_override("font_color", text_cold.lerp(text_warm, t))


func _on_menu() -> void:
	GameState.reset_run()
	GameState.change_scene(GameState.MENU_SCENE)
