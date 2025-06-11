extends Camera2D

var shadow_ref
var player_ref

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player1")

func _process(delta: float) -> void:
	shadow_ref = get_tree().get_first_node_in_group("shadow")
	#Kamera Lerping
	var pos_diff = player_ref.global_position - shadow_ref.global_position
	var camera_pos: float
	if  pos_diff.x < -200:
		camera_pos = player_ref.global_position.x - 860
	elif pos_diff.x > 200:
		camera_pos = player_ref.global_position.x - 1060
	else:
		camera_pos = player_ref.global_position.x + (pos_diff.x * (-0.5)) - 960
	global_position.x = camera_pos #lerp(global_position.x, camera_pos, 0.01)
	global_position.y = -740
