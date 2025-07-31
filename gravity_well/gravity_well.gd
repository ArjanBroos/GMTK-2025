class_name GravityWell
extends Node2D

@export var area: Area2D
@export var pullFactor: float = 10.0

var affectedAsteroids: Array[Asteroid]

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	for asteroid in affectedAsteroids:
		var force = _determine_force(asteroid)
		asteroid.apply_central_force(force)

func _on_body_entered(asteroid: Asteroid) -> void:
	print("Asteroid entered")
	affectedAsteroids.append(asteroid)

func _on_body_exited(asteroid: Asteroid) -> void:
	print("Asteroid left")
	affectedAsteroids.erase(asteroid)

func _determine_force(asteroid: Asteroid) -> Vector2:
	var vector = asteroid.to_global(global_position)
	var distance = vector.length()
	var direction = vector.normalized()
	return (pullFactor / distance*distance) * direction
