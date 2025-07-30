class_name FollowCursor
extends Node2D

@export var follower: Node2D

func _process(_delta):
	follower.global_position = get_global_mouse_position()
