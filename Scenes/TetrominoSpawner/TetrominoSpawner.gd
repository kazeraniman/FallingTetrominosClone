extends Node2D

var Utility = preload("res://Scripts/Utility.gd")

var IBlock = preload("res://Scenes/Tetromino/IBlock/IBlock.tscn")
var JBlock = preload("res://Scenes/Tetromino/JBlock/JBlock.tscn")
var LBlock = preload("res://Scenes/Tetromino/LBlock/LBlock.tscn")
var OBlock = preload("res://Scenes/Tetromino/OBlock/OBlock.tscn")
var SBlock = preload("res://Scenes/Tetromino/SBlock/SBlock.tscn")
var TBlock = preload("res://Scenes/Tetromino/TBlock/TBlock.tscn")
var ZBlock = preload("res://Scenes/Tetromino/ZBlock/ZBlock.tscn")

func generate_tetromino():
	"""
	Instances a random tetromino.
	"""
	var tetromino_type = Utility.tetromino_types[randi() % Utility.tetromino_types.size()]
	match tetromino_type:
		Utility.IBLOCK:
			return IBlock.instance()
		Utility.JBLOCK:
			return JBlock.instance()
		Utility.LBLOCK:
			return LBlock.instance()
		Utility.OBLOCK:
			return OBlock.instance()
		Utility.SBLOCK:
			return SBlock.instance()
		Utility.TBLOCK:
			return TBlock.instance()
		Utility.ZBLOCK:
			return ZBlock.instance()
