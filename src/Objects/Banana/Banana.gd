extends AnimatedSprite

func _ready():
	play("place")


func _on_Hurtbox_area_entered(area):
	SoundControler.pub_play_effect("res://Objects/Banana/Banane3.wav",3)
	queue_free()
