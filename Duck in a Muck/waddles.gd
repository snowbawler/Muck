extends CharacterBody2D

@export var friction = .25
@export var acceleration = .2
@export var speed : float = 300.0
@export var jump_height : float = 128.0
@export var jump_time_to_peak : float = .3
@export var jump_time_to_descent : float = .1
@export var pop_force_magnitude : float = 20

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var v
var screen_size
var bubbleReady = true
var popStart = false
var popEnd = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var landed = true
var playing = false

#handles waddles motion(input and external forces) and animation
func _physics_process(delta):
	plopSound()
	physX(delta)
	animation()

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_ready():
	screen_size = get_viewport_rect().size 
	hide()

#horizontal motion(friction and acceleration) and flip sprite
func get_input():
	var dir = 0
	if Input.is_action_pressed("right"):
		$AnimatedSprite2D.flip_h = velocity.x < 0
		dir += 1
	if Input.is_action_pressed("left"):
		$AnimatedSprite2D.flip_h = velocity.x < 0
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

#animation
func animation():
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if velocity.y < 0:
		$AnimatedSprite2D.animation = 'jump'
	elif velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
	else:
		$AnimatedSprite2D.animation = 'idle'
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false

#helper method to manage jump
func jump():
	velocity.y = jump_velocity
	
#switches gravity between falling and jumping
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func plopSound():
	if is_on_floor() and abs(velocity.x) > 10:
		if not playing:
			$quack.play()
			playing = true
	else:
		$quack.stop()
		playing = false
	if velocity.y > 900:
		landed = false
	if is_on_floor() and not landed:
		$plop.play()
		landed = true

#handles jump and collisions
func physX(delta):
	velocity.y += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		$JumpSound.play()
	if popEnd:
		popEnd = false
		pop()
	if sticky():
		animationWhenSticky()
	#if sticky_wall():
		#StickyWallAnimation()
	if is_on_floor() and !sticky():
		friction = frictionVal()
		get_input()
	else:
		collide_on_wall()
	move_and_slide()
	
func animationWhenSticky():
	if Input.is_action_pressed("left"):
		$AnimatedSprite2D.flip_h = true
	if Input.is_action_pressed("right"):
		$AnimatedSprite2D.flip_h = false
	
func StickyWallAnimation():
	velocity.y = 0
	if popEnd:
		popEnd = false
		pop()
	
func frictionVal():
	var tilem = get_parent().get_node("TileMap")
	var tilemap_position = tilem.local_to_map(Vector2(position.x,position.y+20))
	var tile_below_player = tilem.get_cell_tile_data(0, tilemap_position)
	if tile_below_player != null:
		return tile_below_player.custom_data_0
	elif !is_on_floor():
		return 0.25

	
func sticky():
	var tilem = get_parent().get_node("TileMap")
	var tilemap_position = tilem.local_to_map(Vector2(position.x,position.y+20))
	var tile_below_player = tilem.get_cell_tile_data(0, tilemap_position)
	if tile_below_player != null:
		return tile_below_player.custom_data_1
		

func sticky_wall():
	var tilem = get_parent().get_node("TileMap")
	var tilemap_position_right = tilem.local_to_map(Vector2(position.x+13,position.y))
	var tilemap_position_left = tilem.local_to_map(Vector2(position.x-13,position.y))
	var tile_to_right_of_player = tilem.get_cell_tile_data(0, tilemap_position_right)
	var tile_to_left_of_player = tilem.get_cell_tile_data(0, tilemap_position_left)
	if tile_to_right_of_player != null:
		return tile_to_right_of_player.custom_data_1
	if tile_to_left_of_player != null:
		return tile_to_left_of_player.custom_data_1

#pop force
func pop():
	velocity.y = -1 * $Bubbles.position.y 
	velocity.x = -1 * $Bubbles.position.x 
	velocity = velocity * pop_force_magnitude
	
#collisions
func collide_on_wall():
	if velocity.x !=0:
		v = velocity.x
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is TileMap:
			if !sticky():
				$bump.play()
			velocity.x = collision.get_normal().x * abs(v)*0.6

func _on_bubbles_bubble_ready():
	bubbleReady = true

func _on_test_level_pop_end():
	popEnd = true


