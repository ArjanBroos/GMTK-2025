extends Node2D
class_name Spawner

var spawn_timer: Timer
var asteroid_scene = preload("res://asteroids/asteroid.tscn")

@export
var spawn_area: CollisionShape2D
@export
var interval: float = 1.0
@export
var min_speed: float = 50.0
@export
var max_speed: float = 120.0

func _ready() -> void:	
	# set up the timer for spawning the asteroids
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	
	spawn_timer.wait_time = interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	spawn_timer.start()
	
func _on_spawn_timer_timeout() -> void:
	# spawn an asteroid randomly in the spawn area
	var spawnSize = spawn_area.shape.get_rect().size
	var origin = spawn_area.global_position - (spawnSize / 2)
	var randX = origin.x + (randf() * spawnSize.x)
	var randY = origin.y + (randf() * spawnSize.y)
	
	var asteroidInstance: Asteroid = asteroid_scene.instantiate()
	add_child(asteroidInstance)
	
	asteroidInstance.global_position = Vector2(randX, randY)
	asteroidInstance.speed = min_speed + (randf() * (max_speed - min_speed))
	
	# set the direction of the spawner compared to the center of the window
	# used for the initial direction of spawned asteroids
	var window_size = DisplayServer.window_get_size()
	var center = Vector2(window_size.x / 2, window_size.y / 2)
	asteroidInstance.direction_degrees = rad_to_deg(asteroidInstance.global_position.angle_to_point(center))
