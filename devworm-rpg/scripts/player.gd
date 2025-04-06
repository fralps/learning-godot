extends CharacterBody2D

const SPEED = 180

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: String = "none"

func _physics_process(delta: float) -> void:
	player_movement()

func player_movement() -> void:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * SPEED

	if input_vector != Vector2.ZERO:
		update_direction(input_vector)
		play_anim(true)
	else:
		play_anim(false)

	move_and_slide()

func update_direction(input_vector: Vector2) -> void:
	if input_vector.x > 0:
		direction = "right"
	elif input_vector.x < 0:
		direction = "left"
	elif input_vector.y > 0:
		direction = "down"
	elif input_vector.y < 0:
		direction = "up"

func play_anim(moving: bool) -> void:
	var animations = {
		"right": "side_walking" if moving else "side_idle",
		"left": "side_walking" if moving else "side_idle",
		"up": "back_walking" if moving else "back_idle",
		"down": "front_walking" if moving else "front_idle"
	}

	if direction in ["right", "left"]:
		animated_sprite.flip_h = (direction == "left")

	animated_sprite.play(animations.get(direction, "front_idle"))
