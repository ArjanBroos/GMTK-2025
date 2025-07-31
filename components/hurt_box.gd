class_name HurtBox
extends Area2D

@export var health: Health

func _ready() -> void:
	connect("area_entered", _on_area_entered)
	collision_layer = 2 # Is on the Hurtboxes layer
	collision_mask = 1 # Collides with the Hitboxes layer
	
func _on_area_entered(hitbox: HitBox) -> void:
	health.take_damage(hitbox.damage)
