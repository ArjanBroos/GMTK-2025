class_name GameOverHud
extends Control

@export var try_again_button: Button

signal player_wants_to_try_again

func _ready() -> void:
	try_again_button.pressed.connect(_on_try_again_pressed)

func _on_try_again_pressed() -> void:
	player_wants_to_try_again.emit()
