extends Node

var save_path = "user://savefile.save"

@onready var score_display : Label = $HUD/Score
@onready var start_display : Label = $HUD/StartGame
@onready var time_display : Label = $HUD/Time
@onready var wait_time : Timer = $Timer
@onready var high_score_display : Label = $HUD/HighScore

#preload obstacles
var bat_scene = preload("res://Prefab/Enemies/bat.tscn")
var mushroom_scene = preload("res://Prefab/Enemies/mushroom.tscn")
var rock1_scene = preload("res://Prefab/Decoration/rock1.tscn")
var rock2_scene = preload("res://Prefab/Decoration/rock2.tscn")
var obstacle_type = [bat_scene, mushroom_scene, rock1_scene, rock2_scene]
var obstacles : Array
var bat_high = [200, 390]

#Player and Camera start position
const PLAYER_START_POS : Vector2 = Vector2(158, 379)
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

# Called when the node enters the scene tree for the first time.
func _ready():
	time_display.text = str(minute) + " minute " + str(second) + " second"
	score_display.text = "Score : " + str(score)
	screen_size = get_window().size
	ground_height = 100
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	Signalbus.connect("game_over", game_over)
	load_data()
	high_score_display.text = "High Score : " + str(stored_high_score)

func new_game():
	game_running = false
	get_tree().paused = false
	
	#reset variables
	score = 0
	score_display.text = "Score : " + str(score)
	speed = START_SPEED
	difficult = 0
	second = 0
	minute = 0
	high_score = stored_high_score
	
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
		
		#update score
		score += 1
		score_display.text = "Score : " + str(score)
		if (score > high_score):
			high_score = score
			high_score_display.text = "High Score : " + str(high_score)
		else:
			high_score_display.text = "High Score : " + str(stored_high_score)
		
		#update ground position
		if ($Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5):
			$Ground.position.x += screen_size.x
			
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
	else:
		if Input.is_action_just_pressed("Jump"):
			Signalbus.emit_signal("start_game")
			game_running = true
			start_display.visible = false
			$Timer.start()


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
			#var obs_x : int = screen_size.x + (score + 700)
			var obs_x : int = $Player.global_position.x + randi_range(1000, 3000)
			var obs_y : int
			if (obs_type == obstacle_type[0]):
				obs_y = screen_size.y - 170 - (obs_height * obs_scale.y / 2) + 5
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

func adjust_difficult():
	difficult = score / 2000
	if (difficult > MAX_DIFFICULT):
		difficult = MAX_DIFFICULT
	#print("Difficult : " + str(difficult))

func game_over():
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	stored_high_score = high_score
	high_score_display.text = "High Score : " + str(stored_high_score)
	save()

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(stored_high_score)
	print("Save data.")

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		stored_high_score = file.get_var(stored_high_score)
		high_score = stored_high_score
		print("Load data.")
	else:
		print("No data saved...")
