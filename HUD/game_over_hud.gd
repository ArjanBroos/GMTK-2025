class_name GameOverHud
extends Control

@export var try_again_button: Button
@export var highscores_button: Button

signal player_wants_to_try_again
signal player_wants_to_see_highscores

func _ready() -> void:
	try_again_button.pressed.connect(_on_try_again_pressed)
	highscores_button.pressed.connect(_on_highscores_pressed)

func _on_try_again_pressed() -> void:
	player_wants_to_try_again.emit()

func _on_highscores_pressed() -> void:
	player_wants_to_see_highscores.emit()
