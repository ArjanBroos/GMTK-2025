class_name NearMissBox
extends Area2D

func _ready() -> void:
    # area_entered.connect(_on_area_entered)
    collision_layer = 1 # Is on the Hurtboxes layer
    collision_mask = 2 # Collides with the Hitboxes layer

# func _on_area_entered(hitbox: HitBox) -> void:
#     print(hitbox.get_class())
#     Signalbus.nearmissSignal.emit()
#     print("this was a near miss")