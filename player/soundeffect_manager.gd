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
@export var multiplierSound: AudioStream
@export var shieldSound: AudioStream

var soundEffectVolume: float = -20
var nearMissArray: Array[AudioStream] 
var nextMissSound: AudioStream
var baseVolume: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nearMissArray = [nearmissSound1, nearmissSound2, nearmissSound3, nearmissSound4, nearmissSound5, nearmissSound6, nearmissSound7, nearmissSound8]
	Signalbus.connect("nearmissSignal", playNearMiss)
	audioPlayer.volume_db = soundEffectVolume
	Signalbus.connect("anchorSound", playAnchorSound)
	Signalbus.connect("gravityWellSpawn", playGravityWellSound)
	Signalbus.connect("multiplierSoundPlay", playMultiplierSound)
	Signalbus.connect("shieldAvailable", playShieldSound)
	baseVolume = anchorAudioPlayer.volume_db

func playNearMiss(_eventPos: Vector2) -> void:
	getNextNearMissSound()
	audioPlayer.stream = nextMissSound
	audioPlayer.playing = true
	audioPlayer.play()

func getNextNearMissSound() -> void:
	nextMissSound = nearMissArray.pick_random()

func playAnchorSound() -> void:	
	anchorAudioPlayer.volume_db = baseVolume
	anchorAudioPlayer.stream = anchorSound
	anchorAudioPlayer.playing = true
	anchorAudioPlayer.play()

func playGravityWellSound() -> void:
	anchorAudioPlayer.volume_db = baseVolume
	anchorAudioPlayer.stream = gravityWellSound
	anchorAudioPlayer.playing = true
	anchorAudioPlayer.play()

func playMultiplierSound() -> void:
	anchorAudioPlayer.volume_db = baseVolume
	anchorAudioPlayer.volume_db -= 20
	anchorAudioPlayer.stream = multiplierSound
	anchorAudioPlayer.playing = true
	anchorAudioPlayer.play()

func playShieldSound() -> void:
	anchorAudioPlayer.volume_db = baseVolume
	anchorAudioPlayer.stream = shieldSound
	anchorAudioPlayer.playing = true
	anchorAudioPlayer.play()
