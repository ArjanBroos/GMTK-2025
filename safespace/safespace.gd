@tool
extends Node2D
class_name SafeSpace

@onready var collision_shape: CollisionPolygon2D = $SafeArea/CollisionShape

@export
var rotation_speed: float = 100.0
@export
var radius: float = 150.0
@export
var arc_length: int = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# reset the editor shape and start making something that actually looks like a pizza slice
	var points: Array[Vector2] = []
	points.append(Vector2.ZERO)
	
	# calculate an arc
	var step = (2 * PI) / 90 # 4 degree steps
	for i in range(arc_length):
		var vec = Vector2(cos(i * step) * radius, sin(i * step) * radius)
		points.append(vec)
	
	points.append(Vector2.ZERO)
	
	collision_shape.polygon = points
	
func _draw() -> void:
	var points: Array[Vector2] = []
	points.append(Vector2.ZERO)
	
	# calculate an arc
	var step = (2 * PI) / 90 # 4 degree steps
	for i in range(arc_length):
		var vec = Vector2(cos(i * step) * radius, sin(i * step) * radius)
		points.append(vec)
	
	points.append(Vector2.ZERO)
	
	collision_shape.polygon = points

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	
	rotate(deg_to_rad(rotation_speed / 100))


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Player entering!")
	pass # Replace with function body.
