extends Node

var playerScore: int = 0
var gameTimer: float = 0.0
var timerRunning: bool = false
var game_over: bool = false
var player: Player
@export var timeLabel: Label
@export var scoreLabel: Label
@export var game_over_hud: GameOverHud
@export var player_spawn_point: Node2D
@export var player_scene: PackedScene
@export_file("*.tscn") var retry_scene_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signal to update score
	Signalbus.connect("increaseScore", updateScore)
	Signalbus.connect("playerDied", _on_player_died)
	game_over_hud.player_wants_to_try_again.connect(_on_player_wants_to_try_again)
	print("starting scene")
	resetScore()
	startTimer()
	_spawn_player()

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

func _on_player_died() -> void:
	stopTimer()
	game_over_hud.visible = true
	game_over = true
	player.queue_free()

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
