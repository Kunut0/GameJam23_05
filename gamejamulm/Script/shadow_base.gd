extends CharacterBody2D

class_name ShadowBase

@onready var sprite
@onready var dash_timer = $DashTimer

var jump_force = 400
var direction
var speed = 400

var dash_speed = 500
var dashing = false
var dash_allowed = true

func _ready() -> void:
	sprite = self.get_node("sprite")

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#gets direction imput
	direction =  Input.get_axis("ui_left", "ui_right")
	
	#checks direction to flip sprite
	if direction < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	#generates character movement
	if direction:
		if dashing:
			velocity.x = dash_speed * direction
		else:
			velocity.x = speed * direction
	else:
		if dashing:
			velocity.x = dash_speed * 1
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	#makes player jump when on floor
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
	
	if Input.is_action_just_pressed("ui_down") and is_on_floor() and dash_allowed:
		dashing = true
		dash_allowed = false
		dash_timer.start()
	
	move_and_slide()


func spawn():
	var respawn_point_array = get_tree().get_nodes_in_group("respawn_point")
	var player_ref = get_tree().get_nodes_in_group("player1")
	var shadow_res = 0
	for i in respawn_point_array: #respawn punkt für shadow wird gewählt
		if respawn_point_array[i].global_position - player_ref.global_position < 0:
			if shadow_res > respawn_point_array[i].global_position - player_ref.global_position or shadow_res == 0:
				shadow_res = respawn_point_array[i].global_position
	global_position = shadow_res
