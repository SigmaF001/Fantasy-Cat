extends Control

var save_path = "user://savefile.save"

@onready var image_focused = preload("res://Asset/UI/Complete_UI_Essential_Pack_Free/01_Flat_Theme/Sprites/UI_Flat_Select01a_1.png")
@onready var select_sound = $SelectSound
@onready var display_coin : Label = $ShowCoin/Container/Coin
@onready var purchase_sound : AudioStreamPlayer = $PurchaseSound

var stored_high_score : int
var hight_coins : int
var pocket_coin : int
var character_name

#Cat Store
var cat_2 : bool
var cat_3 : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/Cat1/Orange0.play("Show")
	$VBoxContainer/HBoxContainer/Cat2/Black0.play("Show")
	$VBoxContainer/HBoxContainer/Cat3/White0.play("Show")
	load_data()
	pocket_coin = GlobalData.coin
	check_store()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	display_coin.text = "Coin : " + str(GlobalData.coin)
	pocket_coin = GlobalData.coin
	
	if (GlobalData.character_name != "orange_0"):
		$VBoxContainer/HBoxContainer/Cat1/Orange0Button.disabled = false
	if (GlobalData.character_name != "black_0"):
		$VBoxContainer/HBoxContainer/Cat2/Black0Button.disabled = false
	if (GlobalData.character_name != "white_0"):
		$VBoxContainer/HBoxContainer/Cat3/White0Button.disabled = false

func check_store():
	if (GlobalData.cat_2 == true):
		$VBoxContainer/HBoxContainer/Cat2/Price.visible = false
	if (GlobalData.cat_3 == true):
		$VBoxContainer/HBoxContainer/Cat3/Price.visible = false

func _on_orange_0_button_pressed():
	GlobalData.character_name = "orange_0"
	$VBoxContainer/HBoxContainer/Cat1/Orange0Button.disabled = true
	select_sound.play()
	save()


func _on_black_0_button_pressed():
	if (GlobalData.cat_2 == false):
		if (GlobalData.coin >= 20):
			purchase_sound.play()
			GlobalData.coin -= 20
			$VBoxContainer/HBoxContainer/Cat2/Price.visible = false
			GlobalData.cat_2 = true
		else:
			pass
	else:
			GlobalData.character_name = "black_0"
			$VBoxContainer/HBoxContainer/Cat2/Black0Button.disabled = true
			select_sound.play()
	save()

func _on_white_0_button_pressed():
	if (GlobalData.cat_3 == false):
		if (GlobalData.coin >= 200):
			purchase_sound.play()
			GlobalData.coin -= 200
			$VBoxContainer/HBoxContainer/Cat3/Price.visible = false
			GlobalData.cat_3 = true
		else:
			pass
	else:
			GlobalData.character_name = "white_0"
			$VBoxContainer/HBoxContainer/Cat3/White0Button.disabled = true
			select_sound.play()
	save()
		
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")


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
		print("cat 2 : " + str(cat_2))
		cat_3 = file.eof_reached()
		print("Load data.")
	else:
		print("No data save")
