class_name GravityWell
extends Node2D

@export var area: Area2D
@export var pullFactor: float = 1500.0
@export var rotationSpeed: float = 1.0

var affectedAsteroids: Array[Asteroid]

func destroy() -> void:
	queue_free()

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	rotate(delta * rotationSpeed)
	for asteroid in affectedAsteroids:
		var force = _determine_force(asteroid)
		asteroid.apply_central_force(force)

func _on_body_entered(asteroid: Asteroid) -> void:
	affectedAsteroids.append(asteroid)

func _on_body_exited(asteroid: Asteroid) -> void:
	affectedAsteroids.erase(asteroid)

func _determine_force(asteroid: Asteroid) -> Vector2:
	var directionToAsteroid = global_position.direction_to(asteroid.global_position)
	var forceDirection = directionToAsteroid.rotated(PI / 2.0)
	var distance = asteroid.global_position.distance_to(global_position)
	return (pullFactor / distance*distance) * forceDirection
