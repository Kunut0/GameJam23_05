extends Node2D

var timer_szene = preload("res://Szene/global_timer.tscn")

func _ready() -> void:
	var timer = timer_szene.instantiate()
	get_tree().root.add_child(timer)
