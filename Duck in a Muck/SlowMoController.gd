extends Node

@export var normal_time_scale: float = 1.0
@export var slowmo_time_scale: float = .2

@onready var slomo_active = false

func start_slomo():
	slomo_active = true
	Engine.time_scale = slowmo_time_scale

func end_slomo():
	slomo_active = false
	Engine.time_scale = normal_time_scale

func _on_test_level_pop_start():
	start_slomo()

func _on_test_level_pop_end():
	end_slomo()
