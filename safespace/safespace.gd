@tool
extends Node2D
class_name SafeSpace

@onready var collision_shape: CollisionPolygon2D = $SafeArea/CollisionShape
@onready var visible_shape: Polygon2D = $SafeArea/VisibleShape

@export
var rotation_speed: float = 100.0
@export_range(0,1000)
var inner_radius: float = 50.0
@export_range(10,1000)
var outer_radius: float = 250.0
@export
var arc_length: int = 15

@export
var pause_in_editor: bool = true

func _calculate_shape() -> Array[Vector2]:
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
	
	return points

func _set_collision_shape(points: Array[Vector2]) -> void:
	# reset the editor shape and start making something that actually looks like a pizza slice
	collision_shape.polygon = points

func _set_visible_shape(points: Array[Vector2]) -> void:
	visible_shape.polygon = points

func _ready() -> void:
	var shape = _calculate_shape()
	_set_collision_shape(shape)
	_set_visible_shape(shape)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# explicitly calculate the shape here because in-editor
		# the _ready function is not called
		var shape = _calculate_shape()
		_set_collision_shape(shape)
		_set_visible_shape(shape)
		queue_redraw()
	
	if !Engine.is_editor_hint() || (Engine.is_editor_hint() && !pause_in_editor):
		rotate(deg_to_rad(rotation_speed / 100))

func _on_area_2d_area_entered(area: Area2D) -> void:
	Signalbus.backInSafety.emit()

func _on_safe_area_area_exited(area: Area2D) -> void:
	Signalbus.outOfSafety.emit()
