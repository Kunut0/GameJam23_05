extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite 
@onready var dash_timer = $DashTimer
@onready var jump_timer = $JumpHeightTimer
@onready var buffering_timer = $BufferingTimer
@onready var firetrail = $Line2D
@onready var hurt = $Hurtbox
@onready var nav = $NavigationAgent2D

var shadow_scene = preload("res://Szene/AngerShadow.tscn")

var jump_force = -900
var direction
var speed = 400

var buffered_input: String

var dash_speed = 700
var dashing = false
var dash_allowed = true
var dash_direction

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
		if GameMode.GameMode == "arcade":
			nav.target_position = get_tree().get_first_node_in_group("player1").global_position
			var p = nav.get_next_path_position() - global_position
			p = p.normalized()
			var d = global_position - get_tree().get_first_node_in_group("player1").global_position
			
			if ((p.y < -0.99 and (d.x > 50 or d.x < -50)) or $RayCast2D.is_colliding()):
				if coyote < 0.1:
					velocity.y = jump_force
					$Jump.play()
			
			if (d.x < -200 or d.x > 300) and coyote < 0.1 and dash_allowed:
				dashing_action()
			
			if p.x < -0.05 or d.x < -400:
				direction = -1
				$RayCast2D.target_position.x = -216
			elif p.x > 0.05:
				direction = 1
				$RayCast2D.target_position.x = 216
			else:
				direction = 0
			
			if fire_allowed:
				firetrailing()


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

func firetrailing():
	fire_allowed = false
	$Ability.play()
	firetrail.get_child(0).adding = 0
	await get_tree().create_timer(1.2).timeout
	firetrail.get_child(0).adding = 1
	await get_tree().create_timer(0.5).timeout
	firetrail.get_child(0).adding = 2
	$"../fire_cooldown".start()
	await $"../fire_cooldown".timeout
	fire_allowed = true

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
	
	firetrail.get_child(0).adding = false
	firetrail.get_child(0).delete_all()
	
	var shadow = shadow_scene.instantiate()
	shadow.global_position = shadow_res
	get_tree().current_scene.call_deferred("add_child", shadow)
	player_ref.shadow_ref = shadow
	
	call_deferred("queue_free")



func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true


func _on_line_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.respawn()


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
			$Jump.play()
			jump_timer.start()
	elif buffered_input == "dash":
		if coyote < 0.1 and dash_allowed:
			dashing_action()
