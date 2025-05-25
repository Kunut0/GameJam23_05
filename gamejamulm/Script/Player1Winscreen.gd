extends Control

var t

func _ready() -> void:
	t = get_tree().root.get_children()
	for i in t:
		if i.is_in_group("global_timer"):
			i.queue_free()
	
	$RichTextLabel.text = "[font_size=112][center]The Shadows were able to prevent the Runner from escaping.[p]"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/Start.tscn")
