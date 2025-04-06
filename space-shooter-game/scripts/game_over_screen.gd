extends Control

@onready var score = $Panel/Score
@onready var high_score = $Panel/HighScore

func set_high_score(value: int) -> void:
	high_score.text = "Hi-score: " + str(value)

func set_score(value: int) -> void:
	score.text = "Score: " + str(value)

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
