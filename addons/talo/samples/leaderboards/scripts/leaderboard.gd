class_name LooperoidsLeaderboard
extends Node2D

var entry_scene = preload("res://addons/talo/samples/leaderboards/entry.tscn")

@export var leaderboard_internal_name: String
@export var include_archived: bool

@onready var leaderboard_name: Label = %LeaderboardName
@onready var entries_container: VBoxContainer = %Entries
@onready var info_label: Label = %InfoLabel
@onready var username: TextEdit = %Username
@onready var score_label: Label = %YourScoreLabel
@onready var back_button: Button = %BackButton

var _entries_error: bool
var _score: int

func set_score(score: int) -> void:
	_score = score
	score_label.text = "Your score: %d   " % _score

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	leaderboard_name.text = leaderboard_name.text.replace("{leaderboard}", leaderboard_internal_name)
	await _load_entries()
	_set_entry_count()

func _set_entry_count():
	if entries_container.get_child_count() == 0:
		info_label.text = "No high scores yet!" if not _entries_error else "Failed loading leaderboard %s." % leaderboard_internal_name
	else:
		info_label.text = "%s entries" % entries_container.get_child_count()

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry_scene.instantiate()
	entry_instance.set_data(entry)
	entries_container.add_child(entry_instance)

func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries = Talo.leaderboards.get_cached_entries(leaderboard_internal_name)

	for entry in entries:
		entry.position = entries.find(entry)
		_create_entry(entry)

func _load_entries() -> void:
	var page := 0
	var done := false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = include_archived

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)

		if not is_instance_valid(res):
			_entries_error = true
			return

		var entries := res.entries
		var is_last_page := res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_build_entries()

func _on_submit_pressed() -> void:
	var name = username.text.strip_edges(true, true).strip_escapes()
	await Talo.players.identify("username", name)

	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, _score)

	_build_entries()

func _on_back_button_pressed() -> void:
	visible = false
