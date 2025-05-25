extends Node2D

var level #= preload("res://Level select.tscn")
var credits = preload("res://Szene/credits.tscn")
@onready var animation: AnimationPlayer = $AnimationPlayer

#func _ready() -> void:
#	BG_MUSIC._play_menu_music()

func _on_start_pressed() -> void:
	animation.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.hide()
	$credits.hide()
	$start.hide()
	$quit.hide()
	$RichTextLabel.hide()
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


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits)
