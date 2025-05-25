extends Control

@onready var credits_text = $RichTextLabel

func _ready() -> void:
	credits_text.text = "[font_size=128][center]CREDITS[p][font_size=48] [p][center]DEVELOPED BY[p][center]Egzon[p][center]Frederick[p][center]Max[p][center]Richard[p] [p] [p][center]Sounds by 
 on Freesounds.org!"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Szene/Start.tscn")
