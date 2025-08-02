@tool
class_name Asteroid
extends RigidBody2D

const CURVE_SMOOTHING: float = 0.25

@export var speed: float = 20.0
@export var direction_degrees: float = 90.0
@export var damp: float = 0.15

@export_group("Body visualization")
@export var nrof_segments: int = 9
@export var radius: float = 10.0
@export var radius_noise: float = 0.3

@onready var outer_line: Line2D = $OuterLine
@onready var body_collision: CollisionPolygon2D = $BodyCollision
@onready var hitbox_collision: CollisionPolygon2D = $HitBox/Collision

var raw_points: Array[Vector2] = []
var shape: Array[Vector2] = []

func _calculate_shape() -> Array[Vector2]:
	raw_points.clear()
	
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

func _set_outer_line(points: Array[Vector2]) -> void:
	outer_line.clear_points()
	for p in points:
		outer_line.add_point(p)

func _set_collisions(point: Array[Vector2]) -> void:
	body_collision.polygon = point
	hitbox_collision.polygon = point

func _init() -> void:
	shape = _calculate_shape()

func set_parameters(new_radius: float, new_radius_noise: float, new_nrof_segments: int) -> void:
	radius = new_radius
	radius_noise = new_radius_noise
	nrof_segments = new_nrof_segments
	shape = _calculate_shape()

func _ready() -> void:
	linear_damp = damp

	_set_outer_line(shape)
	_set_collisions(shape)

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var dirVec = Vector2.RIGHT.rotated(deg_to_rad(direction_degrees))
	apply_central_force(dirVec * speed)

func _determine_mirror_position(cur_pos: Vector2) -> Vector2:
	var window = DisplayServer.window_get_size()
	
	# positions are determined by taking the window width/height and resetting
	# the position of the asteroid to either the 0 or window width/height based
	# on where on the screen the asteroid left
	
	var new_pos: Vector2
	
	if cur_pos.x > window.x:
		# exited on the right
		new_pos = Vector2(0, clamp(cur_pos.y, 0, window.y))
	elif cur_pos.x < 0:
		# exited on the left
		new_pos = Vector2(window.x, clamp(cur_pos.y, 0, window.y))
	elif cur_pos.y > window.y:
		# exited at the bottom
		new_pos = Vector2(clamp(cur_pos.x, 0, window.x), 0)
	elif cur_pos.y < 0:
		# exited at the top
		new_pos = Vector2(clamp(cur_pos.x, 0, window.x), window.y)
		
	return new_pos

func _on_visible_on_screen_screen_exited() -> void:
	global_position = _determine_mirror_position(global_position)
	Signalbus.increaseScore.emit(1)
