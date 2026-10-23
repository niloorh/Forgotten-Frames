extends Control

@export var level_number: int = 0
@export var level_type: int = 0
@export var player_ability: int = 0

@onready var next_button = $Button
@onready var current_scene = \
	get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_button.pressed.connect(self.next_stage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func next_stage():
	current_scene.queue_free()
	var new_scene = ResourceLoader.load("res://Scenes/game.tscn")
	current_scene = new_scene.instantiate()
	current_scene.level_number = level_number
	current_scene.level_type = level_type
	current_scene.player_ability = player_ability
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
