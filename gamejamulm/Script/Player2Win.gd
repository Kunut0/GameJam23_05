extends Control

var t

func _ready() -> void:
	GlobalTimer.stop()
	
	$RichTextLabel.text = "[font_size=112][center]The Shadows were able to prevent the Runner from escaping.[p]"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/Start.tscn")
