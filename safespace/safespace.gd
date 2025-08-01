@tool
extends Node2D
class_name SafeSpace

@onready var collision_shape: CollisionPolygon2D = $SafeArea/CollisionShape

@export
var rotation_speed: float = 100.0
@export_range(0,1000)
var inner_radius: float = 25.0
@export_range(10,1000)
var outer_radius: float = 150.0
@export
var arc_length: int = 15

func _calculate_collision_shape() -> void:
	# reset the editor shape and start making something that actually looks like a pizza slice
	var points: Array[Vector2] = []
	var step = (2 * PI) / 90 # 4 degree steps
	
	# calculate the outer arc first
	for i in range(arc_length):
		var vec = Vector2(cos(i * step) * outer_radius, sin(i * step) * outer_radius)
		points.append(vec)
		
	# calculate the inner arc second, but in reverse
	for i in range(arc_length - 1, -1, -1):
		var vec = Vector2(cos(i * step) * inner_radius, sin(i * step) * inner_radius)
		points.append(vec)
	
	collision_shape.polygon = points

func _ready() -> void:
	_calculate_collision_shape()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# explicitly calculate the shape here because in-editor
		# the _ready function is not called
		_calculate_collision_shape()
		queue_redraw()
	
	rotate(deg_to_rad(rotation_speed / 100))

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Player entering!")
	pass # Replace with function body.
