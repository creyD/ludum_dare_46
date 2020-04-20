extends AnimatedSprite

func _ready():
	play("place")


func _on_Hurtbox_area_entered(area):
	queue_free()
