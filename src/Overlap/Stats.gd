extends Node

export(int) var max_health := 1
onready var health := max_health setget set_health

export(int) var max_speed := 125
onready var speed := max_speed setget set_speed

signal no_health

func set_health(value):
	health = value
	if health < 1:
		emit_signal("no_health")
		
func set_speed(value):
	if value > max_speed:
		speed = max_speed
	else:
		speed = value


