extends "res://Scenes/Tetromino/Tetromino.gd"

func _ready():
	piece_type = Utility.LBLOCK
	piece_matrix = [
		[Utility.EMPTY, Utility.EMPTY, Utility.PIECE],
		[Utility.PIECE, Utility.PIECE, Utility.PIECE],
		[Utility.EMPTY, Utility.EMPTY, Utility.EMPTY]
	]
