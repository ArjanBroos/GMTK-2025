class_name Tether
extends Line2D

@export var player: Player
@export var max_length: float = 150.0
@export var activation_period_in_seconds: float = 5.0
@export var anchor: Node2D
@export var tether_activation_timer: Timer

var current_length
var activation_period_left
var activated
var initial_length

func _activate() -> void:
	activated = true
	visible = true
	anchor.visible = true

@onready var shield_collision_shape: CollisionShape2D = $"../Player/ShieldBox/ShieldCollisionShape"
@onready var shield_outline: Line2D = $"../Player/ShieldBox/ShieldOutline"
@onready var shield_timer: Timer = $"../Player/ShieldTimer"
@onready var shield_cooldown_timer: Timer = $"../Player/ShieldCooldownTimer"

func _ready() -> void:
	activated = false
	visible = false
	anchor.visible = false
	activation_period_left = activation_period_in_seconds
	initial_length = 800.0
	current_length = initial_length
	tether_activation_timer.timeout.connect(_activate)
	_update_line()
	shield_timer.timeout.connect(_despawn_shield)
	shield_cooldown_timer.timeout.connect(_restore_shield_availability)

	# calculate shield outline
	var segments = 22
	var step = (2 * PI) / segments
	var radius = (shield_collision_shape.shape as CircleShape2D).radius

	# calculate a circle of points, adding noise for each point to make mountains and valleys
	for i in range(segments):
		var vec = Vector2(cos(i * step) * radius, sin(i * step) * radius)
		shield_outline.add_point(vec)

func _process(delta: float) -> void:
	_update_tether_length(delta)
	_clamp_player_pos()
	_update_line()
	if Input.is_action_just_pressed("trigger_shield"):
		_spawn_shield()

func _update_tether_length(delta: float) -> void:
	if activated:
		if activation_period_left > 0.0:
			activation_period_left -= delta
			current_length = lerp(initial_length, max_length, 1.0 - activation_period_left / activation_period_in_seconds)
		else:
			current_length = max_length

func _clamp_player_pos() -> void:
	var direction = global_position.direction_to(player.global_position)
	var distance = global_position.distance_to(player.global_position)
	if (distance > current_length):
		player.global_position = global_position + current_length * direction

func _update_line() -> void:
	set_point_position(1, to_local(player.global_position))
	var distance = global_position.distance_to(player.global_position)
	var proportion = distance / current_length
	default_color = Color(1.0, 1.0 - proportion, 1.0 - proportion, proportion*proportion / 2)

func _on_near_miss_box_body_exited(_body: Node2D) -> void:
	Signalbus.nearmissSignal.emit(player.global_position)

func _spawn_shield() -> void:
	if shield_cooldown_timer.is_stopped():
		shield_collision_shape.disabled = false
		shield_outline.visible = true
		shield_timer.start()
		shield_cooldown_timer.start()
		Signalbus.shieldUnavailable.emit()

func _despawn_shield() -> void:
	shield_collision_shape.disabled = true
	shield_outline.visible = false

func _restore_shield_availability() -> void:
	Signalbus.shieldAvailable.emit()

func _on_shield_box_body_entered(body: Node2D) -> void:
	if body is Asteroid:
		var explosion = player.explosion_scene.instantiate() as EmitParticlesAndDestroy
		get_tree().root.add_child(explosion)
		explosion.global_position = body.global_position
		explosion.emit_particles_and_destroy()
		(body as Asteroid).destroy()
