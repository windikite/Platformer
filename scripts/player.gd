extends CharacterBody2D
@export var movement_data : PlayerMovementData
var jumped = false
var double_jumped = false
var attacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var wall_touch = %WallTouch
@onready var attack_timer = %attackTimer
@onready var gcd_timer = %GCDTimer
@onready var starting_position = global_position

func _physics_process(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")
	check_attacks()
	if attacking == true:
		return
	apply_gravity(delta)
	check_jump()
	check_movement(input_axis, delta)
	update_animations(input_axis)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func check_jump():
	if is_on_floor(): 
		jumped = false
		double_jumped = false
	
	if is_on_wall() and wall_touch.time_left == 0.0:
		wall_touch.start()
	
	if wall_touch.time_left > 0.0 and not is_on_floor():
		var wall_normal = get_wall_normal()
		if Input.is_action_pressed("ui_left") and Input.is_action_just_pressed("ui_select") and wall_normal == Vector2.LEFT:
			velocity.y = movement_data.jump_velocity
			velocity.x = wall_normal.x * movement_data.speed
			jumped = true
		elif Input.is_action_pressed("ui_right") and Input.is_action_just_pressed("ui_select") and wall_normal == Vector2.RIGHT:
			velocity.y = movement_data.jump_velocity
			velocity.x = wall_normal.x * movement_data.speed
			jumped = true
	
	if jumped == false:
		if Input.is_action_just_pressed("ui_select"):
			velocity.y = movement_data.jump_velocity
			jumped = true
	else:
		if Input.is_action_just_released("ui_select") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2 
			
		if Input.is_action_just_pressed("ui_select") and double_jumped == false: 
			velocity.y = movement_data.jump_velocity * 0.5
			double_jumped = true

func check_movement(input_axis, delta):
	if input_axis:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		else: 
			velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func check_attacks():
	if Input.is_action_just_pressed("ui_click") and gcd_timer.time_left == 0.0:
		attack_timer.start()
		gcd_timer.start()
		attacking = true
	if attack_timer.time_left > 0.0: 
		animated_sprite_2d.play("attack1")
	else:
		attacking = false
		
func update_animations(input_axis):
	if input_axis:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
		


func _on_hazard_detector_area_entered(area):
	global_position = starting_position
