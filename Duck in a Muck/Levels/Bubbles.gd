extends AnimatedSprite2D

@export var speed = 3
var time = 0
var slo = false
signal bubbleReady

func _ready():
	play("default")

func _process(delta):
	if !slo:
		var radius = 30
		time += delta
		position = Vector2(
			sin(time * speed) * radius,
			cos(time * speed) * radius
		)

func _on_animation_finished():
	if animation == "grow":
		slo = false
		_ready()
		bubbleReady.emit()
	if animation == "pop":
		play("grow")
		$grow.play()
		
func _on_test_level_pop_start():
	slo = true

func _on_test_level_pop_end():
	play("pop")
	$pop.play()
