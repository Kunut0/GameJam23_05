extends Control

func _ready() -> void:
	GlobalTimer.stop()
	
	$RichTextLabel.text = "[font_size=112][center]The Runner was able to by pass [code]" + str(GameMode.clearedRooms) + "[/code] rooms.[p]"
	
	GameMode.GameMode = "default"
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/Start.tscn")
