class_name Player
extends Node2D

@export var health: Health
@export var explosion_scene: PackedScene

func _ready() -> void:
	health.died.connect(_on_died)

func _on_died() -> void:
	var explosion = explosion_scene.instantiate() as EmitParticlesAndDestroy
	get_tree().root.add_child(explosion)
	explosion.global_position = global_position
	explosion.emit_particles_and_destroy()
	Signalbus.playerDied.emit()
