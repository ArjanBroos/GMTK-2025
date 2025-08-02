class_name FollowCursor
extends Node2D

@export var follower: Node2D
@export var max_speed: float = 300.0

func _process(delta):
	var pos = follower.global_position
	var mousePos = get_global_mouse_position()
	var direction = pos.direction_to(mousePos)
	var distance = pos.distance_to(mousePos)
	follower.global_position = pos.move_toward(mousePos, max_speed * delta)
	if distance > 1.0:
		follower.rotation = Vector2.UP.angle_to(direction)
