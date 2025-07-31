class_name Health
extends Node

@export var max_health: int = 1

signal took_damage(amount: int) # For on hit effects
signal died() # For determining whether player died

var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	took_damage.emit(amount)
	if (current_health == 0):
		died.emit()
