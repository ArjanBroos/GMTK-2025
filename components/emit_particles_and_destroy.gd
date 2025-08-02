class_name EmitParticlesAndDestroy
extends Node

@export var particles: CPUParticles2D

func emit_particles_and_destroy() -> void:
	particles.emitting = true
	particles.finished.connect(_on_particles_finished)

func _on_particles_finished() -> void:
	queue_free()
