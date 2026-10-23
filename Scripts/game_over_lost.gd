extends Control

@onready var button = $Button
@onready var current_scene = \
	get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(self.main_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func main_menu():
	current_scene.queue_free()
	var new_scene = ResourceLoader.load("res://Scenes/main_menu.tscn")
	current_scene = new_scene.instantiate()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
