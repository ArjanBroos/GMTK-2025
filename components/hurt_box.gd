class_name HurtBox
extends Area2D

@export var health: Health

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	collision_layer = 2 # Is on the Hurtboxes layer
	collision_mask = 1 # Collides with the Hitboxes layer
	
func _on_area_entered(area: CollisionObject2D) -> void:
	match area.name:
		"HitBox":
			health.take_damage(area.damage)

func _on_area_exited(area: CollisionObject2D) -> void:
	match area.name:
		"NearMissBox":
			Signalbus.nearmissSignal.emit()
