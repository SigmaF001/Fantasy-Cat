extends CharacterBody2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

const JUMP_VELOCITY = -600.0

var begin : bool = false
var dive_ground : bool = false
# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Signalbus.connect("start_game", start_game)
	Signalbus.connect("game_over", game_over)
	animation_player.play("Idle")

func _physics_process(delta):
	if (!dive_ground):
		# If player did'n dive to a ground add the gravity
		velocity.y += gravity * delta
	if (begin):
		if is_on_floor():
				# Handle jump
			if (Input.is_action_just_pressed("Jump")):
				velocity.y = JUMP_VELOCITY
				$JumpSound.play()
			elif (Input.is_action_pressed("Down")):
				animation_player.play("Slide")
				$RunCol/RunCollision.disabled = true
				$CrouchCol/CrouchCollision.disabled = false
				$StandardCollision.disabled = true
				$SlideCollision.disabled = false
			else:
				animation_player.play("Run")
				$RunCol/RunCollision.disabled = false
				$CrouchCol/CrouchCollision.disabled = true
				$StandardCollision.disabled = false
				$SlideCollision.disabled = true
		else:
			animation_player.play("Jump")
			if (Input.is_action_pressed("Down")):
				dive_ground = true
				velocity.y += 3000 * delta
			else:
				dive_ground = false
	else:
		animation_player.play("Idle")

	move_and_slide()

func start_game():
	begin = true
	
func game_over():
	begin = false
	dive_ground = false

func _on_run_col_area_entered(area):
	if (area.is_in_group("obs")):
		print("Die!")
		Signalbus.emit_signal("game_over")


func _on_crouch_col_area_entered(area):
	if (area.is_in_group("obs")):
		print("Die!")
		Signalbus.emit_signal("game_over")
