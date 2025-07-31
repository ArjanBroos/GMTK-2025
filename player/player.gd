class_name Player
extends Node2D

@export var health: Health

func _ready() -> void:
	health.died.connect(_on_died)

func _on_died() -> void:
	Signalbus.playerDied.emit()
