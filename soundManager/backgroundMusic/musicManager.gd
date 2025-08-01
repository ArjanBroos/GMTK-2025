extends Node

@export var bgMusicPlayer: AudioStreamPlayer
@export var stage1Music: AudioStream
@export var stage2Music: AudioStream
@export var stage3Music: AudioStream
@export var gameoverMusic: AudioStream
var stageLevel: int = 0
var musicLengthTimer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# set up the timer for spawning the asteroids
	musicLengthTimer = Timer.new()
	add_child(musicLengthTimer)
	musicLengthTimer.timeout.connect(getStageLevel)
	musicLengthTimer.start()

	# Connect other signals
	Signalbus.connect("playerDied", resetStage)
	Signalbus.connect("increaseMusicStage", increaseStageLevel)
	stageLevel = 1
	setMusicStage(stageLevel)


func resetStage() -> void:
	stageLevel = 0
	setMusicStage(stageLevel)

func getStageLevel() -> void:
	setMusicStage(stageLevel)

# Increase the stage level
func increaseStageLevel() -> void:
	if stageLevel + 1 <=3: 
		stageLevel += 1
		# print("increasing music level to level: " + str(stageLevel))

# set stage for the background music
func setMusicStage(level: int) -> void:
	# print("level of the music now is " + str(level))
	match int(level):
		0:
			bgMusicPlayer.stream = gameoverMusic			
		1: 
			bgMusicPlayer.stream = stage1Music
		2:
			bgMusicPlayer.stream = stage2Music
		3: 
			bgMusicPlayer.stream = stage3Music
	#print(bgMusicPlayer.stream.get_length())
	musicLengthTimer.start(bgMusicPlayer.stream.get_length())
	bgMusicPlayer.play()
