extends CanvasLayer
## "Try to Remember" flashback shown before a boss fight. Runs while paused.

signal confirmed

func setup(boss: Dictionary) -> void:
    %TitleLabel.text = String(boss.get("name", "???"))
    var label: Label = %TextLabel
    label.text = String(boss.get("flashback", ""))
    label.visible_ratio = 0.0
    var tw := create_tween()
    tw.tween_property(label, "visible_ratio", 1.0, maxf(1.5, label.text.length() * 0.035))
    %ConfirmButton.pressed.connect(_on_confirm)
    %CancelButton.pressed.connect(_on_cancel)


func _on_confirm() -> void:
    %ConfirmButton.disabled = true
    %CancelButton.disabled = true
    confirmed.emit()


func _on_cancel() -> void:
    get_tree().paused = false
    queue_free()
