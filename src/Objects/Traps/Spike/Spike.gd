extends Node2D

export(float, 0.1, 3.0) var time_to_recharge = 3.0

var time = Timer.new()

func _ready():
	add_child(time)
	$Sprite.play("out")
	$"Hitbox/CollisionShape2D".disabled = true

func on_timer_timeout():
	$Sprite.play("out")
	time.stop()

func _on_Sprite_animation_finished():
	if $Sprite.get_animation() == "default":
		$"Hitbox/CollisionShape2D".disabled = false		
	if $Sprite.get_animation() == "out":
		$Sprite.play("default")
	elif $Sprite.get_animation() == "in":
		$Sprite.play("in_frozen")
		$"Hitbox/CollisionShape2D".disabled = true
	elif $Sprite.get_animation() == "in_frozen":
		time.connect("timeout", self, "on_timer_timeout")
		time.set_wait_time(time_to_recharge)
		time.start()


func _on_Hitbox_area_entered(area):
	if($Sprite.get_animation()=="default"):
		$Sprite.play("in")


