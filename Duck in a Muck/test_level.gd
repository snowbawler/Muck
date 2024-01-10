extends Node2D

@onready var slowmocontroller = $SlowMoController
@onready var popBuffer = .1
var bubbleReady = true
var poptimer = 0.0
var popPressed = false
signal popStart
signal popEnd

func _ready():
	$Waddles.start($StartPosition.position)
	$Music.play()

func _process(_delta):
	screenWrap()
	cameraMotion()

func cameraMotion():
	var waddlesPosition = $Waddles.position.y
	var screenNumber =  int(waddlesPosition / 576)
	$Camera2D.position.y =  screenNumber * 576 - 288
	#changeBackground()

func screenWrap():
	$Waddles.position.x = wrapf($Waddles.position.x, 0, 1024)

func changeBackground():
	var waddlesPosition = $Waddles.position.y
	var screenNumber =  int(waddlesPosition / 576)
	if screenNumber == 0:
		$Camera2D/TextureRect/Sprite2D.visible = true
		$Camera2D/TextureRect.flip_h = false
		$Camera2D/TextureRect.flip_v = false
	if screenNumber == -1:
		$Camera2D/TextureRect/Sprite2D.visible = false
		$Camera2D/TextureRect.flip_h = true
		$Camera2D/TextureRect.flip_v = true
		#$TextureRect.texture
	if screenNumber == -2:
		$Camera2D/TextureRect.flip_h = true
		$Camera2D/TextureRect.flip_v = false
		

func _physics_process(delta):
	popPhysics(delta)
		
func popPhysics(delta):
	if Input.is_action_pressed("pop"):
		if popPressed and bubbleReady:
			popStart.emit()
			poptimer += delta
	if Input.is_action_just_released("pop"):
		popPressed = false
	if Input.is_action_just_pressed("pop"):
		popPressed = true
		if bubbleReady:
			popStart.emit()
	if (Input.is_action_just_released("pop") or poptimer >= popBuffer) and bubbleReady:
		bubbleReady = false
		poptimer=0
		popEnd.emit()

func _on_bubbles_bubble_ready():
	poptimer = 0
	bubbleReady = true


func _on_end_scene_activator_body_entered(_body):
	if _body == $Waddles:
		get_tree().change_scene_to_file("res://end_scene.tscn")
