extends Area2D

@export var newScene: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		get_tree().call_deferred("change_scene_to_file", newScene)
	elif get_tree().current_scene.name == "tutorial_2" and body.is_in_group("shadow"):
		get_tree().call_deferred("change_scene_to_file", newScene)
