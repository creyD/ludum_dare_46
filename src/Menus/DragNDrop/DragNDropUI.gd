extends Control

var usedCards = [cards.BARREL,cards.BEAR,cards.EMPTY,cards.EMPTY,cards.EMPTY]
onready var HBox = $HBoxContainer

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
	pass

export var ObjectParent:NodePath

func update_cards():
	for child in HBox.get_children():
		child.queue_free()
	
	for card in usedCards:
		var newchild
		match card:
			cards.BANANA:
				newchild=load("res://Objects/Banana/BananaCard.tscn").instance()
			cards.BARRIERE:
				newchild=(load("res://Objects/Barriere/BarrierCard.tscn").instance())
			cards.BARREL:
				newchild=(load("res://Objects/Barrel/BarrelCard.tscn").instance())
			cards.TORCH:
				newchild=(load("res://Objects/Torch/TorchCard.tscn").instance())
			cards.BEAR:
				newchild=(load("res://Objects/Traps/Bear/BearCard.tscn").instance())
			cards.FLAME:
				newchild=(load("res://Objects/Traps/Flame/FlameCard.tscn").instance())
			cards.SPIKE:
				newchild=(load("res://Objects/Traps/Spike/SpikeCard.tscn").instance())
			#cards.SLIME:
				#newchild=(load("res://Objects/Slime/SlimeCard.tscn").instance())
		if(newchild!=null):
			HBox.add_child(newchild)

