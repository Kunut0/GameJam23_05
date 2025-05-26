extends Area2D

@export var newScene: String

var SceneArray = ["res://Szene/level_grief.tscn", "res://Szene/level_anxiety.tscn", "res://Szene/level_anger.tscn"]

var i = 3

func _on_body_entered(body: Node2D) -> void:
	if GameMode.GameMode == "default":
		if body.is_in_group("player1"):
			get_tree().call_deferred("change_scene_to_file", newScene)
		elif get_tree().current_scene.name == "tutorial_2" and body.is_in_group("shadow"):
			get_tree().call_deferred("change_scene_to_file", newScene)
	
	elif GameMode.GameMode == "arcade":
		if body.is_in_group("player1"):
			i = randi_range(0, 2)
			get_tree().call_deferred("change_scene_to_file", SceneArray[i])
			GameMode.clearedRoom += 1
