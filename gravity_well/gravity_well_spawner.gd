class_name GravityWellSpawner
extends Area2D

@export var initial_spawn_timer: Timer
@export var inter_spawn_timer: Timer
@export var gravity_well_scene: PackedScene
@export var spawn_area: CollisionShape2D

var well: GravityWell

func _ready() -> void:
	initial_spawn_timer.timeout.connect(_spawn)
	inter_spawn_timer.timeout.connect(_spawn)

func _spawn() -> void:
	if well != null:
		well.destroy()
	well = gravity_well_scene.instantiate()
	add_child(well)
	well.global_position = _pick_position()
	inter_spawn_timer.start()

func _pick_position() -> Vector2:
	var spawnSize = spawn_area.shape.get_rect().size
	var origin = spawn_area.global_position - (spawnSize / 2)
	var randX = origin.x + (randf() * spawnSize.x)
	var randY = origin.y + (randf() * spawnSize.y)
	return Vector2(randX, randY)
