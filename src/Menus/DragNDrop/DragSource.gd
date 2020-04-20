extends TextureRect
# CardDeck
var canNotPlace = false
export var Item:PackedScene
export var PreviewIcon:Texture 
export var DeleteOnGrab:bool = false

var card_level = 0

#if a drag is initiated here 
func get_drag_data(_pos):
	if (canNotPlace):
		return null
	var ctrl = Control.new()
	var TR = TextureRect.new()
	TR.texture = get_resized_texture(PreviewIcon, self.rect_size[0], self.rect_size[1])
	TR.rect_size = self.rect_size
	TR.set_position(_pos * -1, false)
	ctrl.add_child(TR)
	set_drag_preview(ctrl)
	
	if DeleteOnGrab:
		self.queue_free()
	return Item


# stuff can be dropped here
# eg you picked the wrong thing up, let go and it returns to nothingness
func can_drop_data(_pos, data):
	return typeof(data) == typeof(PackedScene)


# do nothing if stuff is dropped here
func drop_data(_pos, _data):
	pass


func get_resized_texture(t: Texture, width: int = 0, height: int = 0):
	var image = t.get_data()
	if width > 0 and height > 0:
		image.resize(width, height)
	var itex = ImageTexture.new()
	itex.create_from_image(image,0)
	return itex


func upgrade_card():
	match card_level:
		0:
			$AnimatedSprite.play("lvl1")
			card_level += 1
		1:
			$AnimatedSprite.play("lvl2")
			card_level += 1
