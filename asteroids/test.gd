@tool
extends Node2D
class_name Test

const CURVE_SMOOTHING: float = 0.25

@export
var nrof_segments: int = 9
@export
var radius: float = 50.0
@export
var radius_noise: float = 0.3

@onready var collision_shape: CollisionPolygon2D = $Shape/CollisionShape
@onready var visible_shape: Line2D = $Shape/VisibleShape

var raw_points: Array[Vector2] = []
var shape: Array[Vector2] = []

func _init() -> void:
	shape = _calculate_shape()

func _calculate_shape() -> Array[Vector2]:
	var step = (2 * PI) / nrof_segments

	# calculate a circle of points, adding noise for each point to make mountains and valleys
	for i in range(nrof_segments):
		var noise = randf_range(radius * (1.0 - radius_noise), radius * (1.0 + radius_noise))
		var vec = Vector2(cos(i * step) * noise, sin(i * step) * noise)
		raw_points.append(vec)

	# re-add the first point so that we get a 'more or less' closed loop
	# will be a sharp ugly connection though, but making it more smoothed is too much work now
	raw_points.append(raw_points[0])

	var curve: Curve2D = Curve2D.new()

	for i in range(raw_points.size()):
		var prev = raw_points[(i - 1) % raw_points.size()]
		var next = raw_points[(i + 1) % raw_points.size()]
		var tangent = (next - prev) * CURVE_SMOOTHING
		curve.add_point(raw_points[i], -tangent, tangent)

	var tesselated: PackedVector2Array = curve.tessellate()

	var retPoints: Array[Vector2] = []

	# unpack the PackedVector2Array into a normal Vector2 array
	# not sure if this is going to bite us in the ass performance wise later
	for i in tesselated.size():
		retPoints.append(tesselated.get(i))

	return retPoints

func _draw() -> void:
	var i = 0
	for p in raw_points:
		draw_circle(p, 1, Color.RED)
		draw_string(ThemeDB.fallback_font, p, str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 8)
		i = i + 1

	for sp in shape:
		draw_circle(sp, 1, Color.BLUE)

# func _set_collision_shape(points: Array[Vector2]) -> void:
# 	# reset the editor shape and start making something that actually looks like a pizza slice
# 	collision_shape.polygon = points

func _set_visible_shape(points: Array[Vector2]) -> void:
	visible_shape.clear_points()
	for p in points:
		visible_shape.add_point(p)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_set_collision_shape(_calculate_shape())
	_set_visible_shape(shape)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint() && !shape.is_empty():
		#_set_collision_shape(shape)
		_set_visible_shape(shape)
		queue_redraw()
