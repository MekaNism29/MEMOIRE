class_name Interactable
extends Area2D
## Base class for anything the player presses [E]/[Enter] on.
## Subclasses override get_prompt() and interact().

@export var prompt_text := "[E] Interaksi"

var player_inside: Node = null


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func get_prompt() -> String:
    return prompt_text


func interact(_player: Node) -> void:
    pass


func refresh_prompt() -> void:
    if player_inside != null:
        GameState.set_prompt(get_prompt())


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_inside = body
        body.current_interactable = self
        GameState.set_prompt(get_prompt())


func _on_body_exited(body: Node2D) -> void:
    if body == player_inside:
        player_inside = null
        if body.current_interactable == self:
            body.current_interactable = null
        GameState.set_prompt("")
