extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition
@onready var laser_container: Node2D = $LaserContainer
@onready var enemy_container: Node2D = $EnemyContainer
@onready var enemies_spawn_timer: Timer = $EnemiesSpawnTimer
@onready var hud: Control = $UILayer/HUD
@onready var game_over_screen: Control = $UILayer/GameOverScreen
@onready var parallax_background: ParallaxBackground = $ParallaxBackground

# SFX
@onready var laser_sound: AudioStreamPlayer = $SFX/LaserSound
@onready var hit_sound: AudioStreamPlayer = $SFX/HitSound
@onready var explode_sound: AudioStreamPlayer = $SFX/ExplodeSound

@export var enemy_scenes: Array[PackedScene] = []

var score: int = 0:
	set(value):
		score = value
		hud.score = score
var high_score: int = 0
var scroll_speed: int = 100

func _ready() -> void:
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file != null:
		high_score = save_file.get_32()
	else:
		high_score = 0
		save_game()

	score = 0
	player.global_position = player_spawn_position.global_position
	player.laser_shot.connect(_on_player_laser_shot)
	player.player_killed.connect(_on_player_killed)
	
func save_game() -> void:
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	# Increase difficuly by spawning enemies faster as the game going
	if enemies_spawn_timer.wait_time > 0.5:
		enemies_spawn_timer.wait_time -= delta * 0.005
	elif enemies_spawn_timer.wait_time < 0.5:
		enemies_spawn_timer.wait_time = 0.5
	
	# Make the background moving fot he parallax effect
	# Reset to 0 when we get to the screen y max size to remove the process bg
	parallax_background.scroll_offset.y += delta * scroll_speed
	if parallax_background.scroll_offset.y >= 960:
		parallax_background.scroll_offset.y = 0
		
func _on_player_laser_shot(laser_scene, location) -> void:
	var laser = laser_scene.instantiate()
	laser.global_position = location
	laser_container.add_child(laser)
	laser_sound.play()

func _on_enemies_spawn_timer_timeout() -> void:
	var enemy: Node = enemy_scenes.pick_random().instantiate()
	enemy.global_position = Vector2(randf_range(50, 500), -50)
	enemy.killed.connect(_on_enemy_killed)
	enemy.hit.connect(_on_enemy_hit)
	enemy_container.add_child(enemy)
	
func _on_enemy_killed(points: int) -> void:
	score += points
	hit_sound.play()
	if score > high_score:
		high_score = score
		
func _on_enemy_hit() -> void:
	hit_sound.play()
	
func _on_player_killed() -> void:
	explode_sound.play()
	game_over_screen.set_score(score)
	game_over_screen.set_high_score(high_score)
	save_game()
	await get_tree().create_timer(1).timeout
	game_over_screen.visible = true
