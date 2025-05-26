extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite 
@onready var dash_timer = $DashTimer
@onready var firetrail = $Line2D
@onready var hurt = $Hurtbox
@onready var nav = $NavigationAgent2D

var jump_force = -1600
var direction
var speed = 750

var dash_speed = 1500
var dashing = false
var dash_allowed = true

var stunned = false
var stun_time

var fire_allowed = true

var trail: Trail
var coyote = 0

func _ready() -> void:
	stun_time = 1

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		velocity += get_gravity() * delta * 4
		coyote += delta
	
	if is_on_floor():
		coyote = 0
	
	if stunned == false:
		if GameMode.GameMode == "default":
			#gets direction imput
			direction =  Input.get_axis("ui_left", "ui_right")
			
			#checks direction to flip sprite
#			if direction < 0:
#				sprite.flip_h = true
#			else:
#				sprite.flip_h = false
			
			#makes player jump when on floor
			if Input.is_action_just_pressed("ui_up") and coyote < 0.1:
				velocity.y = jump_force
				$Jump.play()
			
			if Input.is_action_just_pressed("ui_down"):
				if is_on_floor() and dash_allowed:
					dashing = true
					dash_allowed = false
					dash_timer.start()
					$Dash.play()
				elif not is_on_floor():
					velocity += get_gravity() * delta * 200
			
			if Input.is_action_just_pressed("ui_ctrl") and fire_allowed:
				fire_allowed = false
				$Ability.play()
				firetrail.get_child(0).adding = true
				await get_tree().create_timer(0.7).timeout
				firetrail.get_child(0).adding = false
				$"../fire_cooldown".start()
				await $"../fire_cooldown".timeout
				fire_allowed = true
	
	
		elif GameMode.GameMode == "arcade":
			nav.target_position = get_tree().get_first_node_in_group("player1").global_position
			var p = nav.get_next_path_position() - global_position
			p = p.normalized()
			var d = global_position - get_tree().get_first_node_in_group("player1").global_position
			
			if (0.5 < p.y or $RayCast2D.is_colliding()) and coyote < 0.1:
				velocity.y = jump_force
				$Jump.play()
			
			if (d.x < -200 or d.x > 300) and coyote < 0.1 and dash_allowed:
				dashing = true
				dash_allowed = false
				dash_timer.start()
				$Dash.play()
			
			if d.x > 0 or d.x < -400:
				direction = -1
				$RayCast2D.scale.y = 1
			elif d.x < 0:
				direction = 1
				$RayCast2D.scale.y = -1
			else:
				direction = 0
			
			if fire_allowed:
				fire_allowed = false
				$Ability.play()
				firetrail.get_child(0).adding = true
				await get_tree().create_timer(0.7).timeout
				firetrail.get_child(0).adding = false
				$"../fire_cooldown".start()
				await $"../fire_cooldown".timeout
				fire_allowed = true



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
	else:
		velocity.x = 0
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	spawn()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.respawn()

func stun():
	stunned = true
	hurt.monitoring = false
	$Stun.visible = true
	$AnimatedSprite2D.modulate = Color("6d6d6d")
	await get_tree().create_timer(stun_time).timeout
	stunned = false
	hurt.monitoring = true
	$AnimatedSprite2D.modulate = Color("ffffff")
	$Stun.visible = false

func spawn():
	var respawn_point_array = get_tree().get_nodes_in_group("respawn_point")
	var player_ref = get_tree().get_first_node_in_group("player1")
	var shadow_res = Vector2(0,0)
	for i in respawn_point_array: #respawn punkt für shadow wird gewählt
		if i.global_position.x - player_ref.global_position.x > 500:
			if shadow_res.x > i.global_position.x or shadow_res.x == 0:
				shadow_res = i.global_position
	global_position = shadow_res
	firetrail.get_child(0).adding = false
	firetrail.get_child(0).delete_all()

func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true


func _on_line_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.respawn()
