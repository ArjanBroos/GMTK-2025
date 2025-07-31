extends Node

var playerScore: int = 0
var gameTimer: float = 0.0
var timerRunning: bool = false
@export var timeLabel: Label
@export var scoreLabel: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signal to update score
	Signalbus.connect("increaseScore", updateScore)
	Signalbus.connect("playerDied", _on_player_died)
	print("starting scene")
	resetScore()
	startTimer()

# Function sets the player score to 0
func resetScore() -> void:
	playerScore = 0
	scoreLabel.text = "Score: 0"

# Adjust player score by x
func updateScore(x:int) -> int:
	playerScore = playerScore + x
	print("score updated " + str(playerScore))
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
	print("Oh no! The player died!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timerRunning:
		updateTimer(delta)
