extends Node2D

@export var next_level: PackedScene

@onready var level_completed: ColorRect = $CanvasLayer/LevelCompleted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_completed.connect(show_level_completed)

func show_level_completed() -> void:
	level_completed.show()
	get_tree().paused = true

	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
