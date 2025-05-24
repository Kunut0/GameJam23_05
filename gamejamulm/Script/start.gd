extends Node2D

var level #= preload("res://Level select.tscn")
var credits #= preload("res://Scenes/credits.tscn")

#func _ready() -> void:
#	BG_MUSIC._play_menu_music()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(level)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits)
