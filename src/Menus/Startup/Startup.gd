extends AnimatedSprite

signal startup_finished
var finished_once := false

export(int) var startup_finish_frame = 65
export(int) var loop_frame = 80

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")

func _process(delta):
	if Input.is_action_just_pressed("skip"):
		frame = startup_finish_frame
		
	if frame > startup_finish_frame:
		if not finished_once:
			emit_signal("startup_finished")
		finished_once = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Startup_animation_finished():
	frame = loop_frame
