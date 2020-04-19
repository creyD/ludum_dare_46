extends Node

export(int) var max_health := 1
onready var health := max_health setget set_health

export(float) var max_speed := 125.0
onready var speed := max_speed setget set_speed

signal no_health

func set_health(value):
	if value > max_health:
		health = max_health
	else:
		health = value
	if health < 1:
		emit_signal("no_health")
		
func set_speed(value):
	if value > max_speed:
		speed = max_speed
	elif value<0.0:
		speed = 0.0
	else:
		speed = value

 
