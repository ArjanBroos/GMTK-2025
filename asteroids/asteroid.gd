@tool
class_name Asteroid
extends RigidBody2D

@export var speed: float = 20.0
@export var direction_degrees: float = 90.0

@onready var direction_line_editor: Line2D = $DirectionLineEditor

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dirVec = Vector2.RIGHT.rotated(deg_to_rad(direction_degrees))
	
	apply_central_force(dirVec * speed)

func _draw() -> void:
	var dir = Vector2.RIGHT.rotated(deg_to_rad(direction_degrees)) * 50
	direction_line_editor.points[1] = dir
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		direction_line_editor.visible = false
