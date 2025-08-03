extends Node2D
class_name NearMiss

const DURATION: float = 2.0

var score: int = 1

@onready var bonus_message: Label = $BonusMessage

func set_score(new_score: int) -> void:
	score = new_score

func _ready() -> void:
	bonus_message.text = "+%s" % score

	var tween = get_tree().create_tween()
	# shift the message a bit further along the top right
	tween.parallel().tween_property(bonus_message, "position", Vector2(10,-10), DURATION)
	# gradually fade out
	tween.parallel().tween_property(bonus_message, "modulate:a", 0, DURATION)
	# and finally kill ourselves
	tween.tween_callback(queue_free)
