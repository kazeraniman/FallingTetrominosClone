extends "res://Scenes/Tetromino/Tetromino.gd"

func _ready():
	piece_type = Utility.TBLOCK
	piece_matrix = [
		[Utility.EMPTY, Utility.PIECE, Utility.EMPTY],
		[Utility.PIECE, Utility.PIECE, Utility.PIECE],
		[Utility.EMPTY, Utility.EMPTY, Utility.EMPTY]
	]
