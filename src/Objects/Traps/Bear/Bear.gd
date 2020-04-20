extends Node2D

func _on_Hurtbox_area_entered(area):
	$AnimatedSprite.play("clap")


func _ready():
	$AnimatedSprite.play("place")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() == "place":
		$AnimatedSprite.play("still")
	elif $AnimatedSprite.get_animation() == "clap":
		queue_free()
