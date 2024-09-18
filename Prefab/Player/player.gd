extends CharacterBody2D

@onready var animation_player : AnimatedSprite2D = $AnimatedSprite2D

@export var main_scene : Node

const JUMP_VELOCITY = -500.0
var is_slide_button : bool = false
var begin : bool = false
var dive_ground : bool = false
# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	GlobalData.connect("start_game", start_game)

func _physics_process(delta):
	if (!dive_ground):
		# If player did'n dive to a ground add the gravity
		velocity.y += gravity * delta
	if (begin):
		if is_on_floor():
				# Handle jump
			if (Input.is_action_just_pressed("Jump")):
				jump()
			elif (Input.is_action_pressed("Down") or is_slide_button):
				dive()
			else:
				animation_player.play(GlobalData.character_name + "_running")
				$RunCol/RunCollision.disabled = false
				$CrouchCol/CrouchCollision.disabled = true
				$StandardCollision.disabled = false
				$SlideCollision.disabled = true
		else:
			if (Input.is_action_pressed("Down")):
				dive()
			else:
				is_slide_button = false
				dive_ground = false
	else:
		animation_player.play(GlobalData.character_name + "_sit")

	move_and_slide()

func jump():
	if (is_on_floor()):
		animation_player.play(GlobalData.character_name + "_jumping")
		$RunCol/RunCollision.position.y = -5
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()
	else:
		$RunCol/RunCollision.position.y = 0

func dive():
	if (is_on_floor()):
		dive_ground = true
		animation_player.play(GlobalData.character_name + "_laydown")
		$RunCol/RunCollision.disabled = true
		$CrouchCol/CrouchCollision.disabled = false
		$StandardCollision.disabled = true
		$SlideCollision.disabled = false
	else:
		dive_ground = true
		velocity.y += 3000 * 1/60

func start_game():
	begin = true
	print("Start Game")
	
func game_over():
	begin = false
	dive_ground = false

func _on_run_col_area_entered(area):
	if (area.is_in_group("obs")):
		print("Die!")
		GlobalData.emit_signal("game_over")
		game_over()
	
	if (area.is_in_group("coin")):
		main_scene.get_coin += 1
		GlobalData.coin += 1


func _on_crouch_col_area_entered(area):
	if (area.is_in_group("obs")):
		print("Die!")
		GlobalData.emit_signal("game_over")
		game_over()
	
	if (area.is_in_group("coin")):
		main_scene.get_coin += 1
		GlobalData.coin += 1

func _on_slide_button_button_down():
	is_slide_button = true
	if (is_on_floor()):
		pass
	else:
		velocity.y += 3000 * 1/60

func _on_slide_button_button_up():
	is_slide_button = false

func _on_jump_button_pressed():
	jump()
