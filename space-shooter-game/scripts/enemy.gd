class_name Enemy extends Area2D

signal killed(points)
signal hit

@export var speed: int = 150
@export var hp: int = 1
@export var points: int = 100

func _physics_process(delta: float) -> void:
	global_position.y += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func die() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
		die()
		
func take_damage(amount):
	hp -= amount
	
	if hp <= 0:
		killed.emit(points)
		die()
	else:
		hit.emit()
