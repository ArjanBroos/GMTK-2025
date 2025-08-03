extends Node2D
class_name Spawner

const POSITION_NOISE: float = 100.0
const TIMER_INCREASE: float = 2.0
const TIMER_MAX_CAP_MULTIPLIER: float = 2.0

var asteroid_scene = preload("res://asteroids/asteroid.tscn")

@export
var spawn_area: CollisionShape2D

@export var spawns: Array[SpawnInfo] = []

func _ready() -> void:
	# spawn a single asteroid once to kick things off
	var one_shot_timer = Timer.new()
	one_shot_timer.wait_time = randf_range(0, 0.3)
	one_shot_timer.one_shot = true
	one_shot_timer.autostart = true
	one_shot_timer.timeout.connect(_spawn_asteroid.bind(spawns[0]))
	add_child(one_shot_timer)

	for sp in spawns:

		# set up the timer for spawning the asteroids
		var spawn_timer = Timer.new()
		add_child(spawn_timer)
		
		var spawn_variation = randf_range(0.9, 1.1)
		spawn_timer.wait_time = sp.interval * spawn_variation
		spawn_timer.timeout.connect(_on_spawn_timer_timeout.bind(sp, spawn_timer))
		
		spawn_timer.start()
	
func _add_position_noise(vec: Vector2) -> Vector2:
	var randomRadius = randf() * POSITION_NOISE
	var randomStep = randf() * 2 * PI
	
	var dirVec = Vector2(cos(randomStep), sin(randomStep)) * randomRadius
	
	return vec + dirVec

func _spawn_asteroid(sp: SpawnInfo) -> void:
	# spawn an asteroid randomly in the spawn area
	var spawnSize = spawn_area.shape.get_rect().size
	var origin = spawn_area.global_position - (spawnSize / 2)
	var randX = origin.x + (randf() * spawnSize.x)
	var randY = origin.y + (randf() * spawnSize.y)
	
	var asteroidInstance: Asteroid = asteroid_scene.instantiate()
	asteroidInstance.set_parameters(sp.radius, sp.radius_noise, sp.nrof_segments)
	asteroidInstance.speed = sp.min_speed + (randf() * (sp.max_speed - sp.min_speed))
	asteroidInstance.mass = sp.mass

	add_child(asteroidInstance)
	# Emit signal for spawning asteroid
	Signalbus.spawnAsteroid.emit()
	
	asteroidInstance.global_position = Vector2(randX, randY)
	
	# set the direction of the spawner compared to the center of the window
	# used for the initial direction of spawned asteroids
	var window_size = DisplayServer.window_get_size()
	var center = Vector2(window_size.x / 2, window_size.y / 2)
	center = _add_position_noise(center)
	asteroidInstance.direction_degrees = rad_to_deg(asteroidInstance.global_position.angle_to_point(center))
	
func _on_spawn_timer_timeout(sp: SpawnInfo, timer: Timer) -> void:
	_spawn_asteroid(sp)

	# if not chunky boi and the timer is still lower than the cap, increase the timer
	# this, so that over time you do not get overwhelmed with asteroids
	if sp.radius < 40 && timer.wait_time < sp.interval * TIMER_MAX_CAP_MULTIPLIER:
		timer.wait_time = timer.wait_time + TIMER_INCREASE
	
	timer.start(timer.wait_time)
