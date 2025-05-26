extends Node2D

var level = ["res://Szene/level_anger.tscn", "res://Szene/level_anxiety.tscn", "res://Szene/level_grief.tscn"]
var credits = preload("res://Szene/credits.tscn")
@onready var animation: AnimationPlayer = $AnimationPlayer


#func _ready() -> void:
#	BG_MUSIC._play_menu_music()

func _on_start_pressed() -> void:
	print("wat")
	animation.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.hide()
	$credits.hide()
	$start.hide()
	$quit.hide()
	$KatharsisFont.hide()
	animation.play("fade_out")
	$Breaking.show()
	await get_tree().create_timer(2).timeout
	animation.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	$Breaking.hide()
	$Broken.show()
	animation.play("fade_out")
	await get_tree().create_timer(2).timeout
	animation.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	
	get_tree().call_deferred("change_scene_to_file", "res://Szene/tutorial.tscn")

func _on_arcade_pressed():
	GameMode.GameMode = "arcade"
	GlobalTimer.wait_time = 300
	GlobalTimer.start()
	MainMenuMusik.stop()
	var i = randi_range(0, 2)
	get_tree().call_deferred("change_scene_to_file", level[i])

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits)
