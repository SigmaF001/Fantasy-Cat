extends Control

var save_path = "user://savefile.save"

var hight_coins : int
var stored_high_score : int
var pocket_coin : int
var center : Vector2
var character_name : String

var cat_2
var cat_3

func _ready():
	center = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)
	load_data()
	GlobalData.coin = pocket_coin

func _process(delta):
	var offset = center - get_global_mouse_position() * 0.1


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scene/main.tscn")


func _on_character_select_pressed():
	get_tree().change_scene_to_file("res://Scene/character_selection.tscn")


func _on_exit_pressed():
	get_tree().quit()

func save():
	#character_name = GlobalData.character_name
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(stored_high_score)
	file.store_var(hight_coins)
	file.store_var(GlobalData.coin)
	file.store_var(GlobalData.character_name)
	file.store_var(GlobalData.cat_2)
	file.store_var(GlobalData.cat_3)
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
		print("Load data.")
	else:
		print("No data save")
