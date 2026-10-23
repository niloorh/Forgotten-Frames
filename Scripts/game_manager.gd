extends Node2D

@export var tile_size: int = 16
@export var level_number: int = 0
@export var level_type: int = 0
@export var player_ability: int = 0

const game_info = [
	# normal mode
	[{
		enemy_count_easy = 1,
		enemy_count_medium = 0,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 2,
		enemy_count_medium = 0,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 1,
		enemy_count_medium = 1,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 0,
		enemy_count_medium = 2,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 0,
		enemy_count_medium = 0,
		enemy_count_hard = 1,
		hazard_count = 0
	}],
	# hard mode
	[{
		enemy_count_easy = 2,
		enemy_count_medium = 0,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 2,
		enemy_count_medium = 1,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 4,
		enemy_count_medium = 0,
		enemy_count_hard = 0,
		hazard_count = 0
	},{
		enemy_count_easy = 0,
		enemy_count_medium = 2,
		enemy_count_hard = 1,
		hazard_count = 0
	},{
		enemy_count_easy = 0,
		enemy_count_medium = 0,
		enemy_count_hard = 3,
		hazard_count = 0
	}]
]

var enemy_count_easy
var enemy_count_medium
var enemy_count_hard
var hazard_count

var player_scene
var player
var player_label

var hazard_scene
var hazards_position = []

var enemy_scene1
var enemy_scene2
var enemy_scene3
var enemy_count
var enemies = []
var enemy_labels = []

var player_position = []
var player_hp = 100
var player_alive = true
var enemies_position = []
var enemies_hp = []
var enemies_alive = []

var rng = RandomNumberGenerator.new()

@onready var current_scene = \
	get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
@onready var stage_label = $stage_label
@onready var player_hit_sfx = $player_hit_sfx
@onready var enemy_hit_sfx = $enemy_hit_sfx
@onready var player_walk_sfx = $player_walk_sfx
@onready var player_ability_sfx = $player_ability_sfx

# check whether two locations are next to eachother
func next_to_eachother(a: Array, b: Array) -> bool:
	if(abs(a[0]-b[0]) == 1 && a[1] == b[1]):
		return true
	if(abs(a[1]-b[1]) == 1 && a[0] == b[0]):
		return true
	return false

func near_eachother(a: Array, b: Array) -> bool:
	return abs(a[0]-b[0]) <= 1 && abs(a[1]-b[1]) <= 1
	
func is_clear(p: Array) -> bool:
	if(p[0] < 0 || p[0] > 7 || p[1] < 0 || p[1] > 7 ):
		return false
	if(p[0] == player_position[0] && p[1] == player_position[1]):
		return false
	for i in range(enemy_count):
		if i < len(enemies_position):
			if(p[0] == enemies_position[i][0] && p[1] == enemies_position[i][1]):
				return false
	return true
	
func is_hazard(p: Array) -> bool:
	if(p[0] < 0 || p[0] > 7 || p[1] < 0 || p[1] > 7 ):
		return false
	for i in range(hazard_count):
		if i < len(hazards_position):
			if(p[0] == hazards_position[i][0] && p[1] == hazards_position[i][1]):
				return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage_label.text = "Stage " + str(level_number+1) \
		+ " (" + ("Normal" if level_type == 0 else "Hard") + ")"
	
	enemy_count_easy = game_info[level_type][level_number].enemy_count_easy
	enemy_count_medium = game_info[level_type][level_number].enemy_count_medium
	enemy_count_hard = game_info[level_type][level_number].enemy_count_hard
	#hazard_count = game_info[level_type][level_number].hazard_count
	hazard_count = rng.randi_range(
		(enemy_count_easy+enemy_count_medium*4+enemy_count_hard*3)/1.5,
		enemy_count_easy+enemy_count_medium*4+enemy_count_hard*3
	)
	
	hazard_scene = preload("res://Scenes/hazard.tscn")
	for i in range(hazard_count):
		var temp = hazard_scene.instantiate()
		add_child(temp)
		var temp_pos = [rng.randi_range(0, 7), rng.randi_range(0, 7)]
		while is_hazard(temp_pos):
			temp_pos = [rng.randi_range(0, 7), rng.randi_range(0, 7)]
		hazards_position.push_back(temp_pos)
		temp.position = Vector2(
			(tile_size*4) + (tile_size/2) + (temp_pos[0] * tile_size),
			(tile_size*2) + (tile_size/2) + (temp_pos[1] * tile_size))
	
	player_scene = preload("res://Scenes/player.tscn")
	player = player_scene.instantiate()
	player_label = player.get_node("Label")
	player.animation_finished.connect(self.play_idle)
	add_child(player)
	
	player_position = [rng.randi_range(0, 7), rng.randi_range(0, 7)]
	while is_hazard(player_position):
		player_position = [rng.randi_range(0, 7), rng.randi_range(0, 7)]
	player.position = Vector2(
		(tile_size*4) + (tile_size/2) + (player_position[0] * tile_size),
		(tile_size*2) + (tile_size/2) + (player_position[1] * tile_size))
	player_label.text = "0_100"
	
	enemy_scene1 = preload("res://Scenes/enemy_1.tscn")
	enemy_scene2 = preload("res://Scenes/enemy_2.tscn")
	enemy_scene3 = preload("res://Scenes/enemy_3.tscn")
	enemy_count = enemy_count_easy + enemy_count_medium + enemy_count_hard
	for i in range(enemy_count):
		if i < enemy_count_easy:
			enemies.push_back([enemy_scene1.instantiate(), 1])
		elif i < enemy_count_easy + enemy_count_medium:
			enemies.push_back([enemy_scene2.instantiate(), 2])
		else: 
			enemies.push_back([enemy_scene3.instantiate(), 3])
		enemy_labels.push_back(enemies[i][0].get_node("Label"))
		add_child(enemies[i][0])
		enemies_hp.push_back(100)
		enemies_alive.push_back(true)
		var temp_pos = [rng.randi_range(0, 7), rng.randi_range(0, 7)]
		while !is_clear(temp_pos):
			temp_pos = [rng.randi_range(0, 7), rng.randi_range(0, 7)]
		enemies_position.push_back(temp_pos)
		enemies[i][0].position = Vector2(
			(tile_size*4) + (tile_size/2) + (enemies_position[i][0] * tile_size),
			(tile_size*2) + (tile_size/2) + (enemies_position[i][1] * tile_size))
		enemy_labels[i].text = str(i+1) + "_100"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if(player_alive):
		# player inputs
		var player_movement = [0, 0]
		var is_enemy_turn = false
		if event.is_action_pressed("space"):
			is_enemy_turn = true
		if event.is_action_pressed("ability_q"):
			if player_ability == 1:
				is_enemy_turn = true
				for i in range(enemy_count):
					if (enemies_alive[i] &&
						(enemies_position[i][0] == player_position[0] ||
						enemies_position[i][1] == player_position[1])):
							enemies_hp[i] -= 75
							enemy_labels[i].text = str(i+1) + "_" + str(enemies_hp[i])
							if(enemies_hp[i] <= 0):
								# enemy died
								enemies_position[i] = [-1,-1]
								enemies_alive[i] = false
								enemies[i][0].queue_free()
			elif player_ability == 2:
				is_enemy_turn = true
				for i in range(enemy_count):
					if (enemies_alive[i] && near_eachother(player_position, enemies_position[i])):
						enemies_hp[i] -= 125
						enemy_labels[i].text = str(i+1) + "_" + str(enemies_hp[i])
						if(enemies_hp[i] <= 0):
							# enemy died
							enemies_position[i] = [-1,-1]
							enemies_alive[i] = false
							enemies[i][0].queue_free()
			#player has used an ability				
			if is_enemy_turn:
				player_ability_sfx.play()
				player_hp -= 25
				player_label.text = "0_" + str(player_hp)
				if(player_hp <= 0):
					# player has died
					player_alive = false
					player_position = [-1, -1]
					player.queue_free()
					check_level_state()
					return
		if event.is_action_pressed("ui_down"):
			player_movement[1] += 1
		if event.is_action_pressed("ui_up"):
			player_movement[1] -= 1
		if event.is_action_pressed("ui_left"):
			player_movement[0] -= 1
		if event.is_action_pressed("ui_right"):
			player_movement[0] += 1
		# player has moved
		if(player_movement[0] != 0 || player_movement[1] != 0):
			var flag = false
			#flag is set to see if player has done any damage
			for i in range(enemy_count):
				if(enemies_alive[i] &&
				player_position[0] + player_movement[0] == enemies_position[i][0] &&
				player_position[1] + player_movement[1] == enemies_position[i][1]):
					# damage enemy instead
					is_enemy_turn = true
					flag = true
					enemies_hp[i] -= 25
					enemy_labels[i].text = str(i+1) + "_" + str(enemies_hp[i])
					if(enemies_hp[i] <= 0):
						# enemy died
						enemies_position[i] = [-1,-1]
						enemies_alive[i] = false
						enemies[i][0].queue_free()
					break
			if flag:
				player_hit_sfx.play()
				player.play("attack")
			else:
				# move if possible
				player_position[0] += player_movement[0]
				player_position[1] += player_movement[1]
				if player_position[0] >= 0 && player_position[0] < 8 \
				&& player_position[1] >= 0 && player_position[1] < 8:
					is_enemy_turn = true
					player_walk_sfx.play()
					player.position = Vector2(
						(tile_size*4) + (tile_size/2) + (player_position[0] * tile_size),
						(tile_size*2) + (tile_size/2) + (player_position[1] * tile_size))
				else:
					#player movement is invalid
					if(player_position[0] > 7):
						player_position[0] = 7
					if(player_position[1] > 7):
						player_position[1] = 7
					if(player_position[0] < 0):
						player_position[0] = 0
					if(player_position[1] < 0):
						player_position[1] = 0
						
		#check to see if player is on hazard				
		if is_enemy_turn && is_hazard(player_position):
			# damage player
			player_hp -= 25
			player_label.text = "0_" + str(player_hp)
			if(player_hp <= 0):
				# player has died
				player_alive = false
				player_position = [-1, -1]
				player.queue_free()
				check_level_state()
				return
				
				#from this part forward it's about ENEMY MOVEMENT
		if(is_enemy_turn):
			# enemies actions
			for i in range(enemy_count):
				if enemies[i][1] == 1:
					if enemy_turn_easy(i):
						#the above func says whether the enemy has killed the played
						check_level_state()
						return
				elif enemies[i][1] == 2:
					if enemy_turn_medium(i):
						check_level_state()
						return
				else: # hard
					if enemy_turn_hard(i):
						check_level_state()
						return
				if is_hazard(enemies_position[i]):
					# damage enemy
					enemies_hp[i] -= 25
					enemy_labels[i].text = str(i+1) + "_" + str(enemies_hp[i])
					if(enemies_hp[i] <= 0):
						# enemy died
						enemies_position[i] = [-1,-1]
						enemies_alive[i] = false
						enemies[i][0].queue_free()
			check_level_state()

func enemy_turn_easy(i: int) -> bool:
	if(enemies_alive[i] && next_to_eachother(player_position, enemies_position[i])):
		# damage player
		enemy_hit_sfx.play()
		player_hp -= 10
		player_label.text = "0_" + str(player_hp)
		if(player_hp <= 0):
			# player has died
			player_alive = false
			player_position = [-1, -1]
			player.queue_free()
			return true
	elif(enemies_alive[i]):
		# move closer
		var has_moved = false
		if (enemies_position[i][0] != player_position[0]):
			if(enemies_position[i][0] > player_position[0]):
				if is_clear([enemies_position[i][0]-1,enemies_position[i][1]]):
					enemies_position[i][0] -= 1
					has_moved = true
			else:
				if is_clear([enemies_position[i][0]+1,enemies_position[i][1]]):
					enemies_position[i][0] += 1
					has_moved = true
		elif (enemies_position[i][1] != player_position[1]):
			if(enemies_position[i][1] > player_position[1]):
				if is_clear([enemies_position[i][0],enemies_position[i][1]-1]):
					enemies_position[i][1] -= 1
					has_moved = true
			else:
				if is_clear([enemies_position[i][0],enemies_position[i][1]+1]):
					enemies_position[i][1] += 1
					has_moved = true
		if !has_moved:
			if is_clear([enemies_position[i][0]-1,enemies_position[i][1]]):
				enemies_position[i][0] -= 1
			elif is_clear([enemies_position[i][0]+1,enemies_position[i][1]]):
				enemies_position[i][0] += 1
			elif is_clear([enemies_position[i][0],enemies_position[i][1]-1]):
				enemies_position[i][1] -= 1
			elif is_clear([enemies_position[i][0],enemies_position[i][1]+1]):
				enemies_position[i][1] += 1
		enemies[i][0].position = Vector2(
			(tile_size*4) + (tile_size/2) + (enemies_position[i][0] * tile_size),
			(tile_size*2) + (tile_size/2) + (enemies_position[i][1] * tile_size))
	return false

func enemy_turn_medium(i: int) -> bool:
	if(enemies_alive[i] && (enemies_position[i][0] == player_position[0]
							|| enemies_position[i][1] == player_position[1])):
		# damage player
		enemy_hit_sfx.play()
		player_hp -= 10
		player_label.text = "0_" + str(player_hp)
		if(player_hp <= 0):
			# player has died
			player_alive = false
			player_position = [-1, -1]
			player.queue_free()
			return true
	elif(enemies_alive[i]):
		# move closer
		var has_moved = false
		if (enemies_position[i][0] != player_position[0]):
			if(enemies_position[i][0] > player_position[0]):
				if is_clear([enemies_position[i][0]-1,enemies_position[i][1]]):
					enemies_position[i][0] -= 1
					has_moved = true
			else:
				if is_clear([enemies_position[i][0]+1,enemies_position[i][1]]):
					enemies_position[i][0] += 1
					has_moved = true
		elif (enemies_position[i][1] != player_position[1]):
			if(enemies_position[i][1] > player_position[1]):
				if is_clear([enemies_position[i][0],enemies_position[i][1]-1]):
					enemies_position[i][1] -= 1
					has_moved = true
			else:
				if is_clear([enemies_position[i][0],enemies_position[i][1]+1]):
					enemies_position[i][1] += 1
					has_moved = true
		if !has_moved:
			if is_clear([enemies_position[i][0]-1,enemies_position[i][1]]):
				enemies_position[i][0] -= 1
			elif is_clear([enemies_position[i][0]+1,enemies_position[i][1]]):
				enemies_position[i][0] += 1
			elif is_clear([enemies_position[i][0],enemies_position[i][1]-1]):
				enemies_position[i][1] -= 1
			elif is_clear([enemies_position[i][0],enemies_position[i][1]+1]):
				enemies_position[i][1] += 1
		enemies[i][0].position = Vector2(
			(tile_size*4) + (tile_size/2) + (enemies_position[i][0] * tile_size),
			(tile_size*2) + (tile_size/2) + (enemies_position[i][1] * tile_size))
	return false

func enemy_turn_hard(i: int) -> bool:
	if(enemies_alive[i] && near_eachother(player_position, enemies_position[i])):
		# damage player
		enemy_hit_sfx.play()
		player_hp -= 30
		player_label.text = "0_" + str(player_hp)
		if(player_hp <= 0):
			# player has died
			player_alive = false
			player_position = [-1, -1]
			player.queue_free()
			return true
	elif(enemies_alive[i]):
		# move closer
		var has_moved = false
		if (enemies_position[i][0] != player_position[0]):
			if(enemies_position[i][0] > player_position[0]):
				if is_clear([enemies_position[i][0]-1,enemies_position[i][1]]):
					enemies_position[i][0] -= 1
					has_moved = true
			else:
				if is_clear([enemies_position[i][0]+1,enemies_position[i][1]]):
					enemies_position[i][0] += 1
					has_moved = true
		elif (enemies_position[i][1] != player_position[1]):
			if(enemies_position[i][1] > player_position[1]):
				if is_clear([enemies_position[i][0],enemies_position[i][1]-1]):
					enemies_position[i][1] -= 1
					has_moved = true
			else:
				if is_clear([enemies_position[i][0],enemies_position[i][1]+1]):
					enemies_position[i][1] += 1
					has_moved = true
		if !has_moved:
			if is_clear([enemies_position[i][0]-1,enemies_position[i][1]]):
				enemies_position[i][0] -= 1
			elif is_clear([enemies_position[i][0]+1,enemies_position[i][1]]):
				enemies_position[i][0] += 1
			elif is_clear([enemies_position[i][0],enemies_position[i][1]-1]):
				enemies_position[i][1] -= 1
			elif is_clear([enemies_position[i][0],enemies_position[i][1]+1]):
				enemies_position[i][1] += 1
		enemies[i][0].position = Vector2(
			(tile_size*4) + (tile_size/2) + (enemies_position[i][0] * tile_size),
			(tile_size*2) + (tile_size/2) + (enemies_position[i][1] * tile_size))
	return false

func check_level_state() -> void:
	if !player_alive:
		current_scene.queue_free()
		var new_scene = ResourceLoader.load("res://Scenes/game_over_lost.tscn")
		current_scene = new_scene.instantiate()
		get_tree().get_root().add_child(current_scene)
		get_tree().set_current_scene(current_scene)
		return
	#flag is tre when all the enemies are dead
	var flag = true
	for i in range(enemy_count):
		flag = flag && !enemies_alive[i]
	if flag:
		current_scene.queue_free()
		#check if player has finished all stages of a mode
		if level_number >= 4:
			var ability_2 = 1 if level_type == 1 else 0
			var new_scene = ResourceLoader.load("res://Scenes/game_over_won.tscn")
			current_scene = new_scene.instantiate()
			current_scene.level_type = level_type
			if FileAccess.file_exists("user://forgotten_frames.save"):
				var save_file = FileAccess.open("user://forgotten_frames.save", FileAccess.READ)
				var json_string = save_file.get_line()
				var json = JSON.new()
				var parse_result = json.parse(json_string)
				if parse_result == OK:
					ability_2 = 1 if json.data.get("unlocked_ability_2", 0) == 1 else ability_2
				save_file.close()
			var save_file = FileAccess.open("user://forgotten_frames.save", FileAccess.WRITE)
			save_file.store_line(JSON.stringify({
				"unlocked_hard_mode": 1,
				"unlocked_ability_1": 1,
				"unlocked_ability_2": ability_2
			}))
		else:
			var new_scene = ResourceLoader.load("res://Scenes/next_stage.tscn")
			current_scene = new_scene.instantiate()
			current_scene.level_number = level_number + 1
			current_scene.level_type = level_type
			current_scene.player_ability = player_ability
		get_tree().get_root().add_child(current_scene)
		get_tree().set_current_scene(current_scene)
		return

func play_idle():
	player.play("default")
