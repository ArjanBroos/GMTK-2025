extends Node

@export var bgMusicPlayer: AudioStreamPlayer
@export var stage1Music: AudioStream
@export var stage2Music: AudioStream
@export var stage3Music: AudioStream
var stageLevel: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("playerDied", resetStage)
	Signalbus.connect("increaseMusicStage", increaseStageLevel)
	resetStage()
	bgMusicPlayer.play()

func resetStage() -> void:
	stageLevel = 0
	setMusicStage(stageLevel)

# Increase the stage level
func increaseStageLevel() -> void:
	if stageLevel + 1 <=3: 
		stageLevel += 1
	setMusicStage(stageLevel)

# set stage for the background music
func setMusicStage(level: int) -> void:
	print("level of the music now is " + str(level))
	match int(level):
		0:
			bgMusicPlayer.stream = stage1Music			
		1: 
			bgMusicPlayer.stream = stage1Music
		2:
			bgMusicPlayer.stream = stage2Music
		3: 
			bgMusicPlayer.stream = stage3Music