extends Node

@export var audioPlayer: AudioStreamPlayer
@export var nearmissSound1: AudioStream
@export var nearmissSound2: AudioStream
@export var nearmissSound3: AudioStream
@export var nearmissSound4: AudioStream
@export var nearmissSound5: AudioStream
@export var nearmissSound6: AudioStream
@export var nearmissSound7: AudioStream
@export var nearmissSound8: AudioStream
@export var anchorAudioPlayer: AudioStreamPlayer
@export var anchorSound: AudioStream
@export var gravityWellSound: AudioStream

var soundEffectVolume: float = -20
var nearMissArray: Array[AudioStream] 
var nextMissSound: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nearMissArray = [nearmissSound1, nearmissSound2, nearmissSound3, nearmissSound4, nearmissSound5, nearmissSound6, nearmissSound7, nearmissSound8]
	Signalbus.connect("nearmissSignal", playNearMiss)
	audioPlayer.volume_db = soundEffectVolume
	Signalbus.connect("anchorSound", playAnchorSound)
	Signalbus.connect("gravityWellSpawn", playGravityWellSound)

func playNearMiss(_eventPos: Vector2) -> void:
	getNextNearMissSound()
	audioPlayer.stream = nextMissSound
	audioPlayer.playing = true
	audioPlayer.play()

func getNextNearMissSound() -> void:
	nextMissSound = nearMissArray.pick_random()

func playAnchorSound() -> void:
	anchorAudioPlayer.stream = anchorSound
	anchorAudioPlayer.playing = true
	anchorAudioPlayer.play()

func playGravityWellSound() -> void:
	anchorAudioPlayer.stream = gravityWellSound
	anchorAudioPlayer.playing = true
	anchorAudioPlayer.play()
