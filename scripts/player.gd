
extends CharacterBody2D

const SPEED := 270.0
const GROUND_ACCEL := 2600.0
const AIR_ACCEL := 1700.0
const FRICTION := 2800.0
const JUMP_VELOCITY := -620.0
const GRAVITY := 1500.0
const MAX_FALL := 900.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12

var current_interactable: Node = null
var facing: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _coyote := 0.0
var _buffer := 0.0
var _was_on_floor := false


func _ready() -> void:
	animated_sprite.play("idle")


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")

	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1

	var accel := GROUND_ACCEL if is_on_floor() else AIR_ACCEL

	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote = maxf(0.0, _coyote - delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)

	if Input.is_action_just_pressed("jump"):
		_buffer = JUMP_BUFFER
	else:
		_buffer = maxf(0.0, _buffer - delta)

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_buffer = 0.0
		_coyote = 0.0
		AudioManager.play_sfx("jump")

	if Input.is_action_just_released("jump") and velocity.y < -200.0:
		velocity.y *= 0.5

	move_and_slide()

	_was_on_floor = is_on_floor()

	if Input.is_action_just_pressed("interact"):
		if current_interactable != null and is_instance_valid(current_interactable):
			current_interactable.interact(self)

	update_animation()


func update_animation() -> void:
	if not is_on_floor():
		if velocity.y < 0:
			pass
		else:
			pass
	elif absf(velocity.x) > 20.0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

	animated_sprite.flip_h = facing < 0
