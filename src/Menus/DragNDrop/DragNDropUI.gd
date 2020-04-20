extends Control

var usedCards = [cards.BARREL,cards.BEAR,cards.EMPTY,cards.EMPTY,cards.EMPTY]
var cardPositions = [Vector2(0,150), Vector2(50,150), Vector2(100,150), Vector2(150,150), Vector2(200, 150)]

enum cards {
	BANANA,
	BARRIERE,
	BARREL,
	TORCH,
	BEAR,
	FLAME,
	SPIKE,
	EMPTY
}

func _ready():
	update_cards()

export var ObjectParent:NodePath

func update_cards():
	var index = 0
	while index < 5 and usedCards[index] != cards.EMPTY:
		index += 1

	for card in range(index + 1):
		var newchild = []
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
			#cards.SLIME:
				#newchild=(load("res://Objects/Slime/SlimeCard.tscn").instance())
	for i in range(index + 1):
		$CardsDisplay.add_child(shownCards[i])
	shownCards[0].set_begin (cardPositions[0])
	shownCards[1].set_begin (cardPositions[1])
	shownCards[2].set_begin (cardPositions[2])

	for i in range(index + 1):
		shownCards[i].canNotPlace = true
		shownCards[i].margin_bottom = shownCards[i].margin_top+32
		shownCards[i].margin_right = shownCards[i].margin_left+32
