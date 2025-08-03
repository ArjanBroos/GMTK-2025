extends Node

const NEAR_MISS_SCORE: int = 10

var playerScore: int = 0
var gameTimer: float = 0.0
var timerRunning: bool = false
var game_over: bool = false
var player: Node2D
var nrAsteroids: int
var deathStopTimeScale:float = 0.2
var deathStopSeconds:float = 2
@export var timeLabel: Label
@export var scoreLabel: Label
@export var game_over_hud: GameOverHud
@export var highscores_hud: LooperoidsLeaderboard
@export var player_spawn_point: Node2D
@export var player_scene: PackedScene
@export_file("*.tscn") var retry_scene_path: String

@onready var unsafe_label: Label = $GUI/unsafeLabel
@onready var grace_period_timer: Timer = $GracePeriodTimer

@onready var deathStopTimer: Timer = $DeathStopTimer

@onready var shield_availability_icon: Line2D = $GUI/ShieldAvailabilityIcon

var nearMissScene = preload("res://HUD/near_miss.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signal to update score
	Signalbus.connect("increaseScore", updateScore)
	Signalbus.connect("playerDied", deathStopToggle)
	Signalbus.playerDied.connect(_destroy_player)
	Signalbus.connect("spawnAsteroid", increaseAsteroidCount)
	Signalbus.connect("outOfSafety", _unsafe_area_entered)
	Signalbus.connect("backInSafety", _safe_area_entered)
	Signalbus.connect("nearmissSignal", _handle_near_miss)
	Signalbus.connect("shieldAvailable", _on_shield_available)
	Signalbus.connect("shieldUnavailable", _on_shield_unavailable)

	shield_availability_icon.points = _calculate_shield_outline()

	grace_period_timer.timeout.connect(deathStopToggle)
	deathStopTimer.timeout.connect(_on_player_died)
	
	game_over_hud.player_wants_to_try_again.connect(_on_player_wants_to_try_again)
	game_over_hud.player_wants_to_see_highscores.connect(_on_player_wants_to_see_highscores)
	print("starting scene")
	resetScore()
	startTimer()
	_spawn_player()
	nrAsteroids = 0
	Engine.time_scale = 1

func _calculate_shield_outline() -> Array[Vector2]:
	var points: Array[Vector2] = []

	# calculate shield outline
	var segments = 22
	var step = (2 * PI) / segments
	var radius = 20

	# calculate a circle of points, adding noise for each point to make mountains and valleys
	for i in range(segments):
		var vec = Vector2(cos(i * step) * radius, sin(i * step) * radius)
		points.append(vec)

	return points

func _on_shield_available() -> void:
	print("shield available received")
	shield_availability_icon.default_color = Color("0c48ff")

func _on_shield_unavailable() -> void:
	print("shield not available received")
	shield_availability_icon.default_color = Color("635b5f")

# Function sets the player score to 0
func resetScore() -> void:
	playerScore = 0
	scoreLabel.text = "Score: 0"

# Adjust player score by x
func updateScore(x:int) -> int:
	if game_over:
		return playerScore
		
	playerScore = playerScore + x
	scoreLabel.text = "Score: " + str(playerScore)
	return playerScore

func _handle_near_miss(eventPos: Vector2) -> void:
	var nearMiss: Node2D = nearMissScene.instantiate()
	add_child(nearMiss)
	# offset the message to the top right
	nearMiss.global_position = eventPos + Vector2(20,-20)
	updateScore(NEAR_MISS_SCORE)

# reset the timer
func startTimer() -> void:
	timerRunning = true
	gameTimer = 0.0
	timeLabel.text = "00:00:00"

# Func to update the elapsed time and update the label
func updateTimer(elapsedTime: float) -> void:
	gameTimer += elapsedTime
	var minutes: float = gameTimer / 60
	var seconds: float = fmod(gameTimer, 60) 
	var mseconds: float = fmod(gameTimer, 1) * 100
	timeLabel.text = str(roundi(floor(minutes))) + ":" + str(roundi(seconds)) + ":" + str(roundi(mseconds))
	timeLabel.text = ("%02d:%02d:%02d" % [minutes, seconds, mseconds])

# Stop timer from running
func stopTimer() -> void:
	timerRunning = false
	print("timer stopped at " + str(gameTimer) + " seconds")

# func _input(event: InputEvent) -> void:
# 	if Input.is_key_pressed(KEY_SPACE):
# 		#TODO testing purposes only: print and then reset timer
# 		stopTimer()
# 		startTimer()
# 		print("emitting signal")
# 		Signalbus.increaseScore.emit(10)
# 		print("finished emitting signal")		

func deathStopToggle() -> void:
	Engine.time_scale = deathStopTimeScale
	stopTimer()
	grace_period_timer.stop()
	deathStopTimer.start(deathStopSeconds*deathStopTimeScale)
	Signalbus.deathShake.emit()

func _destroy_player() -> void:
	player.queue_free()

func _on_player_died() -> void:
	Signalbus.stopShake.emit()
	Engine.time_scale = 0
	game_over_hud.visible = true
	game_over = true

func _on_player_wants_to_try_again() -> void:
	game_over_hud.visible = false
	game_over = false
	get_tree().change_scene_to_file(retry_scene_path)

func _on_player_wants_to_see_highscores() -> void:
	highscores_hud.visible = true
	highscores_hud.set_score(playerScore)

func _spawn_player() -> void:
	player = player_scene.instantiate()
	player_spawn_point.add_child(player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timerRunning:
		updateTimer(delta)
	if !grace_period_timer.is_stopped() && unsafe_label.visible:
		unsafe_label.text = "Warning!
Unsafe area entered! " + str("%0.2f" % (grace_period_timer.time_left))

# Function to track asteroid count, also increases the music stage at certain amounts
func increaseAsteroidCount() -> void:
	nrAsteroids += 1
	# TODO Makes some sensible amount for switching the music
	if nrAsteroids == 5 || nrAsteroids == 10:
		Signalbus.increaseMusicStage.emit()
		
func _unsafe_area_entered() -> void:
	unsafe_label.visible = true
	grace_period_timer.start()
	
func _safe_area_entered() -> void:
	unsafe_label.visible = false
	grace_period_timer.stop()
