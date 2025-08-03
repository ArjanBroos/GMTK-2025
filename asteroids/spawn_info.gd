extends Resource
class_name SpawnInfo

@export_range(0,1000) var interval: float = 1.0
@export_range(0,10000) var min_speed: float = 50.0
@export_range(1,10000) var max_speed: float = 120.0

@export_range(1,99) var nrof_segments: int = 9
@export_range(1,1000) var radius: float = 10.0
@export_range(0,10) var radius_noise: float = 0.3
@export_range(1,1000) var mass: float = 1.0
