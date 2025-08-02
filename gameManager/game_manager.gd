extends Node

var playerScore: int = 0
var gameTimer: float = 0.0
var timerRunning: bool = false
var game_over: bool = false
var player: Node2D
var nrAsteroids: int
var nearMissBonus: int = 1
var deathStopTimeScale:float = 0.02
var deathStopSeconds:float = 2
@export var timeLabel: Label
@export var scoreLabel: Label
@export var game_over_hud: GameOverHud
@export var player_spawn_point: Node2D
@export var player_scene: PackedScene
@export_file("*.tscn") var retry_scene_path: String

@onready var unsafe_label: Label = $GUI/unsafeLabel
@onready var grace_period_timer: Timer = $GracePeriodTimer

@onready var deathStopTimer: Timer = $DeathStopTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signal to update score
	Signalbus.connect("increaseScore", updateScore)
	Signalbus.connect("playerDied", deathStopToggle)
	Signalbus.connect("spawnAsteroid", increaseAsteroidCount)
	Signalbus.connect("outOfSafety", _unsafe_area_entered)
	Signalbus.connect("backInSafety", _safe_area_entered)
	Signalbus.connect("nearmissSignal", updateScore.bind(nearMissBonus))
	
	grace_period_timer.timeout.connect(deathStopToggle)
	deathStopTimer.timeout.connect(_on_player_died)
	
	game_over_hud.player_wants_to_try_again.connect(_on_player_wants_to_try_again)
	print("starting scene")
	resetScore()
	startTimer()
	_spawn_player()
	nrAsteroids = 0
	Engine.time_scale = 1

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

func _on_player_died() -> void:
	Engine.time_scale = 0
	game_over_hud.visible = true
	game_over = true
	# TODO: not sure why the queue_free breaks the game in my implementation but it works without
	#player.queue_free()


func _on_player_wants_to_try_again() -> void:
	game_over_hud.visible = false
	game_over = false
	get_tree().change_scene_to_file(retry_scene_path)

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
