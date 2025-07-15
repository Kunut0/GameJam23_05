extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var jump_timer = $JumpHeightTimer
@onready var buffering_timer = $BufferingTimer
@onready var hurt = $Hurtbox
@onready var scream_sprite: Sprite2D = $Area2D/Sprite2D
@onready var nav = $NavigationAgent2D

var shadow_scene = preload("res://Szene/AnxietyShadow.tscn")

signal scream

var jump_force = -2000
var direction
var speed = 600

var buffered_input: String

var dash_speed = 1100
var dashing = false
var dash_allowed = true
var dash_direction

var stunned = false
var stun_time

var scream_allowed = true

var coyote = 0

func _ready() -> void:
	stun_time = 2

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
		if GameMode.GameMode == "arcade":
			nav.target_position = get_tree().get_first_node_in_group("player1").global_position
			var p = nav.get_next_path_position() - global_position
			p = p.normalized()
			var d = global_position - get_tree().get_first_node_in_group("player1").global_position
			
			
			if ((p.y < -0.99 and (d.x > 40 or d.x < -40)) or $RayCast2D.is_colliding()) and coyote < 0.1:
				velocity.y = jump_force
				$Jump.play(1)
			
			if (d.x < -400 or d.x > 400) and coyote < 0.1 and dash_allowed:
				dashing_action()
			
			if p.x < -0.05 or d.x < -500:
				direction = -1
				$RayCast2D.target_position.x = -22.941
			elif p.x > 0.05:
				direction = 1
				$RayCast2D.target_position.x = 22.941
			else:
				direction = 0
			
			if scream_allowed:
				screaming()
		
		#generates character movement
		if direction:
			if dashing:
				velocity.x = dash_speed * direction
			else:
				velocity.x = speed * direction
		else:
			if dashing:
				velocity.x = dash_speed * dash_direction
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		
	else:
		velocity.x = 0
	move_and_slide()

func dashing_action():
	$Dash.play()
	dashing = true
	dash_allowed = false
	dash_timer.start()

func screaming():
	scream_allowed = false
	sprite.play("scream")
	scream_sprite.self_modulate.a = 0.5
	scream_sprite.show()
	$Ability.play()
	
	await get_tree().create_timer(0.7).timeout
	
	scream_sprite.self_modulate.a = 1
	sprite.scale += Vector2(0.05, 0.05)
	scream.emit()
	
	await get_tree().create_timer(0.2).timeout
	
	scream_sprite.hide()
	sprite.scale = Vector2(0.138, 0.138)
	sprite.play("default")
	
	await get_tree().create_timer(2).timeout
	
	scream_allowed = true

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
	stop_stun()

func stop_stun():
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
	
	var shadow = shadow_scene.instantiate()
	shadow.global_position = shadow_res
	get_tree().current_scene.call_deferred("add_child", shadow)
	player_ref.shadow_ref = shadow
	
	call_deferred("queue_free")


func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.25).timeout
	dash_allowed = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		scream.connect(body.stun)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		scream.disconnect(body.stun)


func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("ui_up"):
		if velocity.y < -200:
			velocity.y = -200
			jump_timer.stop()
	elif is_on_floor():
		jump_timer.stop()


func _on_buffering_timer_timeout() -> void:
	if buffered_input == "jump":
		if coyote < 0.1:
			velocity.y = jump_force
			$Jump.play(1)
			jump_timer.start()
	elif buffered_input == "dash":
		if coyote < 0.1 and dash_allowed:
			dashing_action()
