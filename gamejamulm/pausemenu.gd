extends CanvasLayer

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_esc"):
		self.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true

func _on_return_pressed() -> void:
	print("yay")
	self.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_mainmenu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Szene/Start.tscn")
	get_tree().paused = false
	MainMenuMusik.play()
