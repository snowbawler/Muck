extends CharacterBody2D


const speed = 30
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player_chase = false

var waddles = null


func _physics_process(delta):
	if not is_on_floor():
		position.y += gravity * delta
		
	if player_chase:
		position = (waddles.position - position)/speed



func _on_enemy_vision_body_entered(body):
	waddles = body
	player_chase = true


func _on_enemy_vision_body_exited(body):
	waddles = null
	player_chase = false
	
func start(pos):
	position = pos
	show()


func _on_ready():
	pass
