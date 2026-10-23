extends Control


@onready var play_button = $Button_play
@onready var mode_button = $mode_toggle
@onready var none_check = $abilities/none
@onready var cross_check = $abilities/cross
@onready var square_check = $abilities/square
@onready var current_scene = \
	get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	
var game_mode = 0
var player_ability = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ResourceLoader.load_threaded_request("res://Scenes/game.tscn")
	mode_button.disabled = true
	none_check.button_pressed = true
	none_check.disabled = true
	cross_check.disabled = true
	square_check.disabled = true
	if FileAccess.file_exists("user://forgotten_frames.save"):
		var save_file = FileAccess.open("user://forgotten_frames.save", FileAccess.READ)
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			mode_button.disabled = json.data.get("unlocked_hard_mode", 0) != 1
			cross_check.disabled = json.data.get("unlocked_ability_1", 0) != 1
			square_check.disabled = json.data.get("unlocked_ability_2", 0) != 1
			none_check.disabled = square_check.disabled && cross_check.disabled
	play_button.pressed.connect(self.load_level)
	mode_button.toggled.connect(self.change_mode)
	none_check.toggled.connect(self.change_ability_none)
	cross_check.toggled.connect(self.change_ability_cross)
	square_check.toggled.connect(self.change_ability_square)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_level():
	current_scene.queue_free()
	var new_scene = ResourceLoader.load("res://Scenes/game.tscn")
	current_scene = new_scene.instantiate()
	current_scene.level_number = 0
	current_scene.level_type = game_mode
	current_scene.player_ability = player_ability
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func change_mode(state):
	game_mode = 1 if state else 0
	
func change_ability_none(state):
	player_ability = 0
	if state:
		cross_check.set_pressed_no_signal(false)
		square_check.set_pressed_no_signal(false)
	else:
		none_check.set_pressed_no_signal(true)
	
func change_ability_cross(state):
	player_ability = 1
	if state:
		none_check.set_pressed_no_signal(false)
		square_check.set_pressed_no_signal(false)
	else:
		cross_check.set_pressed_no_signal(true)
	
func change_ability_square(state):
	player_ability = 2
	if state:
		cross_check.set_pressed_no_signal(false)
		none_check.set_pressed_no_signal(false)
	else:
		square_check.set_pressed_no_signal(true)
