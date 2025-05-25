class_name Trail
extends Line2D
const max_points = 20

@onready var curve := Curve2D.new()
var collision = preload("res://Szene/firetrail_collision.tscn")

var player_ref
var shadow_ref
var adding = false
var i = 0

func _ready() -> void:
	shadow_ref = get_tree().get_first_node_in_group("shadow")
	player_ref = get_tree().get_first_node_in_group("player1")

func _physics_process(delta: float) -> void:
	var pos = shadow_ref.global_position
	if adding:
		curve.add_point(pos)
		var c = collision.instantiate()
		c.global_position = shadow_ref.global_position
		get_parent().add_child(c)
		i += 1
	else:
		i = 0
		if curve.point_count > 0:
			for i in get_parent().get_children():
				if i.global_position == curve.get_point_position(0):
					i.queue_free()
			curve.remove_point(0)
		else:
			for i in get_tree().get_nodes_in_group("shadow_prop"):
				i.queue_free()
	points = curve.get_baked_points()
	
	
