class_name HitBox
extends Area2D

@export var damage: int = 1

func _ready() -> void:
	collision_layer = 1 # Is on the Hitboxes layer
	collision_mask = 2 # Collides with the Hurtboxes layer
