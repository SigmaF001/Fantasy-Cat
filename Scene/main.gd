extends Node

var save_path = "user://savefile.save"

@onready var score_display : Label = $HUD/VBoxContainer/Panel/Container/Score
@onready var coin_display : Label = $HUD/VBoxContainer/Panel2/Container/Coin
@onready var start_display : Label = $HUD/StartGame
@onready var time_display : Label = $HUD/Time
@onready var wait_time : Timer = $Timer

var character_name : String

#Cat shop
var cat_2
var cat_3

var pocket_coin : int
#preload obstacles
var bat_scene = preload("res://Prefab/Enemies/bat.tscn")
var mushroom_scene = preload("res://Prefab/Enemies/mushroom.tscn")
var rock1_scene = preload("res://Prefab/Decoration/rock1.tscn")
var rock2_scene = preload("res://Prefab/Decoration/rock2.tscn")
var floor_scene = preload("res://Prefab/Decoration/floor.tscn")
var obstacle_type = [bat_scene, mushroom_scene, rock1_scene, rock2_scene]
var obstacles : Array
var coins : Array
var coin_scene = preload("res://Prefab/Decoration/coin.tscn")
var bat_high = [200, 390]

#Player and Camera start position
const PLAYER_START_POS : Vector2 = Vector2(158, 506)
const CAM_START_POS : Vector2 = Vector2(576, 325)
const MAX_DIFFICULT : int = 2
var speed : float
var score : int
var high_score : int
var stored_high_score : int = 0
const SCORE_MODIFER : int = 10
const START_SPEED : float = 10.0
const MAX_SPEED : float = 20.0
var screen_size : Vector2i
var ground_height : int
var second : int
var minute : int
var game_running : bool
var last_obs
var difficult : int
var get_coin : int
var hight_coins : int
var long_minute : int
var long_second : int

# Called when the node enters the scene tree for the first time.
func _ready():
	time_display.text = str(minute) + " minute " + str(second) + " second"
	screen_size = get_window().size
	ground_height = 100
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	GlobalData.connect("game_over", game_over)
	load_data()
	score_display.text = "High score : " + str(stored_high_score)
	coin_display.text = "High coins : " + str(hight_coins)
	pocket_coin = GlobalData.coin
	character_name = GlobalData.character_name

func new_game():
	game_running = false
	get_tree().paused = false
	print(last_obs)
	
	#reset variables
	get_coin = 0
	score = 0
	speed = START_SPEED
	difficult = 0
	second = 0
	minute = 0
	high_score = stored_high_score
	
	score_display.text = "High score : " + str(stored_high_score)
	coin_display.text = "High coins : " + str(hight_coins)
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
		obstacles.clear()
	
	#reset_node
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	start_display.visible = true
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (game_running):
		generate_obs()
		generate_coin()
		
		speed = START_SPEED + score / 200
		adjust_difficult()
		
		#move player and camera
		$Player.position.x += speed
		$Camera2D.position.x += speed
		
		#update time
		if (second >= 60):
			minute += 1
			second = 0
		time_display.text = str(minute) + " minute " + str(second) + " second"
		
		coin_display.text = "Coin : " + str(get_coin)
		if (get_coin >= hight_coins):
			hight_coins = get_coin
		
		#update score
		score += 1
		score_display.text = "Score : " + str(score)
		if (score >= high_score):
			high_score = score
		
		#update ground position
		if ($Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5):
			$Ground.position.x += screen_size.x
			
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
	else:
		if Input.is_action_just_pressed("Jump"):
			GlobalData.emit_signal("start_game")
			$FloorGenTime.start()
			game_running = true
			start_display.visible = false
			$Timer.start()
			
	print(pocket_coin)

	if (Input.is_action_just_pressed("ui_cancel")):
		pass

func _on_timer_timeout():
	second += 1
	#update difficult (every 1 second increase speed by 0.1)
	if (speed < MAX_SPEED):
		speed += 0.1
	else:
		pass

func generate_obs():
	#generate ground obstacles
	if (obstacles.is_empty() or last_obs.position.x < $Player.global_position.x):
		var obs_type = obstacle_type[randi() % obstacle_type.size()]
		var obs
		var max_obs = difficult
		for i in range(max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = $Player.global_position.x + randi_range(1000, 3000)
			var obs_y : int
			if (obs_type == obstacle_type[0]):
				obs_y = randi_range(screen_size.y - 140 - (obs_height * obs_scale.y / 2) + 5, screen_size.y - 200 - (obs_height * obs_scale.y / 2) + 5)
			else:
				obs_y = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
		obs.position = Vector2i(x, y)
		add_child(obs)
		obstacles.append(obs)
		
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func generate_coin():
	var random_y = [screen_size.y - 150, screen_size.y - 300]
	var coin_item = coin_scene
	var gen_coin = coin_item.instantiate()
	var coin_x = randi_range($Player.global_position.x + 1000, $Player.global_position.x + 80000)
	var coin_y = random_y[randi() % random_y.size()]
	gen_coin.position = Vector2i(coin_x, coin_y)
	add_child(gen_coin)
	
func generate_floor():
	var random_x = [$Player.global_position.x + 1000, $Player.global_position.x + 2000, $Player.global_position.x + 3000, $Player.global_position.x + 5000]
	var random_y = [400, 449, 249, 149]
	var floor_ins = floor_scene
	var gen_floor = floor_ins.instantiate()
	var x = random_x[randi() % random_x.size()]
	var y = random_y[randi() % random_y.size()]
	gen_floor.position = Vector2i(x, y)
	add_child(gen_floor)
	obstacles.append(gen_floor )

func adjust_difficult():
	difficult = score / 700
	if (difficult > MAX_DIFFICULT):
		difficult = MAX_DIFFICULT
	#print("Difficult : " + str(difficult))

func game_over():
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	stored_high_score = high_score
	pocket_coin = pocket_coin + get_coin
	save()

func save():
	#character_name = GlobalData.character_name
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(stored_high_score)
	file.store_var(hight_coins)
	file.store_var(pocket_coin)
	file.store_var(character_name)
	file.store_var(cat_2)
	file.store_var(cat_3)
	print("Save data.")

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		stored_high_score = file.get_var(stored_high_score)
		hight_coins = file.get_var(hight_coins)
		pocket_coin = file.get_var(pocket_coin)
		character_name = file.get_line()
		cat_2 = file.eof_reached()
		cat_3 = file.eof_reached()
		GlobalData.character_name = character_name
		print("Load data.")
	else:
		print("No data save")

func _on_floor_gen_time_timeout():
	generate_floor()


func _on_area_2d_body_entered(body):
	if (body.is_in_group("player")):
		game_over()


func _on_button_pressed():
	new_game()
