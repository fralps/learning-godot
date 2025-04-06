class_name Player extends CharacterBody2D

const SPEED: int = 300

signal laser_shot(laser_scene, location)
signal player_killed

@onready var front_of_ship: Marker2D = $FrontOfShip

@export var fire_rate: float = 0.25

var laser_scene: PackedScene = preload("res://scenes/laser.tscn")
var shoot_cooldown: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if !shoot_cooldown:
			shoot_cooldown = true
			shoot()
			await get_tree().create_timer(fire_rate).timeout
			shoot_cooldown = false

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2(
		Input.get_axis("left","right"), Input.get_axis("up", "down")
	)
	velocity = direction * SPEED
	move_and_slide()
	
	global_position = global_position.clamp(Vector2.ZERO, get_viewport_rect().size)
	
func shoot():
	laser_shot.emit(laser_scene, front_of_ship.global_position)
	
func die() -> void:
	player_killed.emit()
	queue_free()
