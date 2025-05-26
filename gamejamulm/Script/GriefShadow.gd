extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var hurt = $Hurtbox
@onready var nav = $NavigationAgent2D

var puddle_scene = preload("res://Szene/puddle.tscn")

var jump_force = -1600
var direction
var speed = 500

var dash_speed = 1200
var dashing = false
var dash_allowed = true

var stunned = false
var stun_time

var puddle_allowed = true

var coyote = 0

func _ready() -> void:
	stun_time = 1.5
	

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		coyote += delta
		if velocity.y > 0:
			velocity += get_gravity() * delta * 8
		else:
			velocity += get_gravity() * delta * 8.75
	
	if is_on_floor():
		coyote = 0
	
	if stunned == false:
		if GameMode.GameMode == "default":
			#gets direction imput
			direction =  Input.get_axis("ui_left", "ui_right")
			
			#checks direction to flip sprite
			if direction < 0:
				sprite.flip_h = false
			elif direction > 0:
				sprite.flip_h = true
			
			
			#makes player jump when on floor
			if Input.is_action_just_pressed("ui_up") and coyote < 0.1:
				velocity.y = jump_force
				$Jump.play()
			
			if Input.is_action_just_pressed("ui_down"):
				if is_on_floor() and dash_allowed:
					$Dash.play()
					dashing = true
					dash_allowed = false
					dash_timer.start()
				elif not is_on_floor():
					velocity += get_gravity() * delta * 200
			
			if Input.is_action_just_pressed("ui_ctrl") and puddle_allowed:
				$Ability.play()
				puddle_allowed = false
				sprite.play("blink")
				var x = -100
				while x <= 100:
					var puddle = puddle_scene.instantiate() #spawns bullet
					puddle.global_position = $PuddleSpawnpoint1.global_position + Vector2(x,0) #set position to marker2D
					get_tree().current_scene.add_child(puddle) #link bullet to tree
					x += 100
				await sprite.animation_finished
				sprite.play("default")
				await get_tree().create_timer(1).timeout
				puddle_allowed = true
		
		elif GameMode.GameMode == "arcade":
			nav.target_position = get_tree().get_first_node_in_group("player1").global_position
			var p = nav.get_next_path_position() - global_position
			p = p.normalized()
			var d = global_position - get_tree().get_first_node_in_group("player1").global_position
			
			if (0.5 < p.y or $RayCast2D.is_colliding()) and coyote < 0.1:
				velocity.y = jump_force
				$Jump.play()
			
			if (d.x < -200 or d.x > 400) and coyote < 0.1 and dash_allowed:
				dashing = true
				dash_allowed = false
				dash_timer.start()
				$Dash.play()
			
			if d.x > 0 or d.x < -300:
				direction = -1
				$RayCast2D.scale.y = 1
				sprite.flip_h = false
			elif d.x < 0:
				direction = 1
				$RayCast2D.scale.y = -1
				sprite.flip_h = true
			else:
				direction = 0
			
			if puddle_allowed:
				$Ability.play()
				puddle_allowed = false
				sprite.play("blink")
				var x = -100
				while x <= 100:
					var puddle = puddle_scene.instantiate() #spawns bullet
					puddle.global_position = $PuddleSpawnpoint1.global_position + Vector2(x,0) #set position to marker2D
					get_tree().current_scene.add_child(puddle) #link bullet to tree
					x += 100
				await sprite.animation_finished
				sprite.play("default")
				await get_tree().create_timer(1).timeout
				puddle_allowed = true
		
		
		
		
		#generates character movement
		if direction:
			if sprite.animation != "blink":
				sprite.play("walk")
			if dashing:
				velocity.x = dash_speed * direction
			else:
				velocity.x = speed * direction
		else:
			if sprite.animation != "blink":
				sprite.play("default")
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
	print("hit")
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


func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true
