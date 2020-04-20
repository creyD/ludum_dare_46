extends Control

var usedCards = [cards.BARREL,cards.BEAR,cards.EMPTY,cards.EMPTY,cards.EMPTY]
var cardPositions = [Vector2(10,223), Vector2(65,223), Vector2(120,223), Vector2(175,223), Vector2(230, 223)]

enum cards {
	BANANA,
	BARRIERE,
	BARREL,
	TORCH,
	BEAR,
	FLAME,
	SPIKE,
	SLIME,
	EMPTY
}

func _ready():
	update_cards()

export var ObjectParent:NodePath

func update_cards():
	var index = 0
	while index < 5 and usedCards[index] != cards.EMPTY:
		index += 1
	var newchild = []
	for card in range(index):
		match usedCards[card]:
			cards.BANANA:
				newchild.append(load("res://Objects/Banana/BananaCard.tscn").instance())
			cards.BARRIERE:
				newchild.append(load("res://Objects/Barriere/BarrierCard.tscn").instance())
			cards.BARREL:
				newchild.append(load("res://Objects/Barrel/BarrelCard.tscn").instance())
			cards.TORCH:
				newchild.append(load("res://Objects/Torch/TorchCard.tscn").instance())
			cards.BEAR:
				newchild.append(load("res://Objects/Traps/Bear/BearCard.tscn").instance())
			cards.FLAME:
				newchild.append(load("res://Objects/Traps/Flame/FlameCard.tscn").instance())
			cards.SPIKE:
				newchild.append(load("res://Objects/Traps/Spike/SpikeCard.tscn").instance())
			cards.SLIME:
				newchild.append(load("res://Objects/Slime/SlimeCard.tscn").instance())
	for i in range(index):
		$CardsDisplay.add_child(newchild[i])
		
	for i in range(index):
		newchild[i].set_begin(cardPositions[i])


	for i in range(index):
		newchild[i].margin_bottom = newchild[i].margin_top+32
		newchild[i].margin_right = newchild[i].margin_left+32
