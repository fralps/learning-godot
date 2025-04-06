extends CharacterBody2D

@export var movement_data : PlayerMovementData

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var starting_position: Vector2 = global_position

var air_jump: bool = false

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_wall_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis := Input.get_axis("move_left", "move_right")

	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animation(input_axis)
	
	var was_on_floor: bool = is_on_floor()
	move_and_slide()
	var just_left_ledge: bool = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	
func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * movement_data.gravity_scale * delta

func handle_wall_jump() -> void:
	if not is_on_wall_only(): return
	
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("move_left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
	if Input.is_action_just_pressed("move_right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity

func handle_jump() -> void:
	if is_on_floor(): air_jump = true

	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

		if Input.is_action_just_pressed("jump") and air_jump:
			velocity.y = movement_data.jump_velocity * 0.7
			air_jump = false

func apply_friction(input_axis: Variant, delta: float) -> void:
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
func apply_air_resistance(input_axis: Variant, delta: float) -> void:
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_acceleration(input_axis: Variant, delta: float) -> void:
	if not is_on_floor(): return

	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis: Variant, delta: float) -> void:
	if is_on_floor(): return
	
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)
	
	

func update_animation(input_axis: Variant) -> void:
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0 )
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area: Area2D) -> void:
	global_position = starting_position
	
