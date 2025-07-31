class_name GravityWell
extends Node2D

@export var area: Area2D
@export var pullFactor: float = 300.0

var affectedAsteroids: Array[Asteroid]

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	for asteroid in affectedAsteroids:
		var force = _determine_force(asteroid)
		asteroid.apply_central_force(force)

func _on_body_entered(asteroid: Asteroid) -> void:
	affectedAsteroids.append(asteroid)

func _on_body_exited(asteroid: Asteroid) -> void:
	affectedAsteroids.erase(asteroid)

func _determine_force(asteroid: Asteroid) -> Vector2:
	var direction = asteroid.global_position.direction_to(global_position)
	var distance = asteroid.global_position.distance_to(global_position)
	return (pullFactor / distance*distance) * direction
