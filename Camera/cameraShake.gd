extends Camera2D

@export var randomStrength: float = 5.0
@export var shakeFade: float = 0.1

var rng = RandomNumberGenerator.new()
var shakeStrenght: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("deathShake", apply_shake)
	Signalbus.connect("stopShake", stop_shake)

func apply_shake():
	shakeStrenght = randomStrength

func stop_shake() -> void:
	shakeStrenght = 0

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrenght, shakeStrenght), rng.randf_range(-shakeStrenght, shakeStrenght))

func _process(delta: float) -> void:
	if shakeStrenght > 0:
		shakeStrenght = lerpf(shakeStrenght, 0, shakeFade * delta)
		offset = randomOffset()
