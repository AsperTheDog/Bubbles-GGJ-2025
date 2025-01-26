extends Control



func _on_button_pressed() -> void:
	var tween: Tween = create_tween()
	await Fade.fade(true)
	get_tree().change_scene_to_file("res://main.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()
