extends Node2D




func _on_start_pressed():
	$ButtonSound.play() 
	$TestLevel.show()
	



func _on_quit_pressed():
	$ButtonSound.play()
	get_tree().quit()
