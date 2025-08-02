class_name Tether
extends Line2D

@export var player: Player
@export var max_length: float = 150.0

func _ready() -> void:
	_update_line()

func _process(delta: float) -> void:
	_clamp_player_pos()
	_update_line()

func _clamp_player_pos() -> void:
	var direction = global_position.direction_to(player.global_position)
	var distance = global_position.distance_to(player.global_position)
	if (distance > max_length):
		player.global_position = global_position + max_length * direction

func _update_line() -> void:
	set_point_position(1, to_local(player.global_position))
	var distance = global_position.distance_to(player.global_position)
	var proportion = distance / max_length
	default_color = Color(1.0, 1.0 - proportion, 1.0 - proportion, proportion*proportion / 2)

func _on_near_miss_box_body_exited(body: Node2D) -> void:
	Signalbus.nearmissSignal.emit()
