extends Area2D

func _on_area_entered(area):
	$CoinSound.play()
	visible = false


func _on_coin_sound_finished():
	queue_free()
