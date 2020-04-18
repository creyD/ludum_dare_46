extends AnimatedSprite

signal startup_finished
var finished_once := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Startup_animation_finished():
	if not finished_once:
		emit_signal("startup_finished")
	finished_once = true
	frame = 80
