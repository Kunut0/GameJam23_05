extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite 
@onready var dash_timer = $DashTimer

var jump_force = -400
var direction
var speed = 400

var dash_speed = 1500
var dashing = false
var dash_allowed = true

var stunned = false
var stun_time

func _ready() -> void:
	speed = 300
	stun_time = 0.3
	

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if stunned == false:
		#gets direction imput
		direction =  Input.get_axis("ui_left", "ui_right")
		
		#checks direction to flip sprite
#		if direction < 0:
#			sprite.flip_h = true
#		else:
#			sprite.flip_h = false
		
		#generates character movement
		if direction:
			if dashing:
				velocity.x = dash_speed * direction
			else:
				velocity.x = speed * direction
		else:
			if dashing:
				velocity.x = dash_speed * -1
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

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	spawn()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.respawn()

func stun():
	stunned = true
	await get_tree().create_timer(stun_time)
	stunned = false

func spawn():
	var respawn_point_array = get_tree().get_nodes_in_group("respawn_point")
	var player_ref = get_tree().get_first_node_in_group("player1")
	var shadow_res = Vector2(0,0)
	for i in respawn_point_array: #respawn punkt für shadow wird gewählt
		if i.global_position.x - player_ref.global_position.x > 200:
			if shadow_res.x > i.global_position.x - player_ref.global_position.x or shadow_res.x == 0:
				shadow_res = i.global_position
	global_position = shadow_res


func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true
