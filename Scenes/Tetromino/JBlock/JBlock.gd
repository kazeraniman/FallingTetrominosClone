extends "res://Scenes/Tetromino/Tetromino.gd"

func _ready():
	piece_type = Utility.JBLOCK
	piece_matrix = [
		[Utility.PIECE, Utility.EMPTY, Utility.EMPTY],
		[Utility.PIECE, Utility.PIECE, Utility.PIECE],
		[Utility.EMPTY, Utility.EMPTY, Utility.EMPTY]
	]
