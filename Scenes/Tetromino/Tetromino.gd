extends Node2D

var Utility = preload("res://Scripts/Utility.gd")

var ROTATION_POSITIONS = 4

var MAIN_WALL_KICKS = {
    0: {
        1: [Vector2(-1, 0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)],
        3: [Vector2(1, 0), Vector2(1, -1), Vector2(0, 2), Vector2(1, 2)]
    },
    1: {
        0: [Vector2(1, 0), Vector2(1, 1), Vector2(0, -2), Vector2(1, -2)],
        2: [Vector2(1, 0), Vector2(1, 1), Vector2(0, -2), Vector2(1, -2)]
    },
    2: {
        1: [Vector2(-1, 0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)],
        3: [Vector2(1, 0), Vector2(1, -1), Vector2(0, 2), Vector2(1, 2)]
    },
    3: {
        2: [Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)],
        0: [Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)]
    }
}

var I_WALL_KICKS = {
    0: {
        1: [Vector2(-2, 0), Vector2(1, 0), Vector2(-2, 1), Vector2(1, -2)],
        3: [Vector2(-1, 0), Vector2(2, 0), Vector2(-1, -2), Vector2(2, 1)]
    },
    1: {
        0: [Vector2(2, 0), Vector2(-1, 0), Vector2(2, -1), Vector2(-1, 2)],
        2: [Vector2(-1, 0), Vector2(2, 0), Vector2(-1, -2), Vector2(2, 1)]
    },
    2: {
        1: [Vector2(1, 0), Vector2(-2, 0), Vector2(1, 2), Vector2(-2, -1)],
        3: [Vector2(2, 0), Vector2(-1, 0), Vector2(2, -1), Vector2(-1, 2)]
    },
    3: {
        2: [Vector2(-2, 0), Vector2(1, 0), Vector2(-2, 1), Vector2(1, -2)],
        0: [Vector2(1, 0), Vector2(-2, 0), Vector2(1, 2), Vector2(-2, -1)]
    }
}

var piece_matrix = [
	[Utility.EMPTY, Utility.PIECE, Utility.EMPTY],
	[Utility.PIECE, Utility.PIECE, Utility.PIECE],
	[Utility.EMPTY, Utility.EMPTY, Utility.EMPTY]
]
var current_rotation_position = 0

func transpose():
	"""
	Returns a new matrix as the transpose of the current piece matrix.
	:return: The transpose of the current piece matrix.
	:rtype: 2D array of TetrominoValues.
	"""
	# Duplicate the piece matrix
	var new_piece_matrix = []
	for row in piece_matrix:
		new_piece_matrix.append(row.duplicate())

	# Perform the transpose
	for i in range(new_piece_matrix.size()):
		for j in range(i+1, new_piece_matrix.size()):
			var temp = new_piece_matrix[i][j]
			new_piece_matrix[i][j] = new_piece_matrix[j][i]
			new_piece_matrix[j][i] = temp

	return new_piece_matrix

func apply_rotation(theoretical_rotation):
	"""
	Applied the rotation to the tetromino given the theorectical structure.
	:param theoretical_rotation: The next piece matrix and the next rotation position.
	:type theoretical_rotation: Dictionary.
	"""
	piece_matrix = theoretical_rotation["new_piece_matrix"]
	current_rotation_position = theoretical_rotation["new_rotation_position"]

func theoretical_rotate(rotation_type):
	"""
	Determines the next piece matrix that would be generated given a particular rotation without altering the current piece matrix, as well as the next rotation position.
	Rotation positions are vital for wall-kicks.
	:param rotation_type: The rotation direction which is requested.
	:type rotation_type: RotationDirections.
	:return: The new piece matrix and the new rotation position.
	:rtype: Dictionary.
	"""
	# Determine the rotated matrix
	var new_piece_matrix = transpose()
	match rotation_type:
		Utility.LEFT:
			new_piece_matrix.invert()
		Utility.RIGHT:
			for row in new_piece_matrix:
				row.invert()

	return {
		"new_piece_matrix": new_piece_matrix,
		"new_rotation_position": (current_rotation_position + rotation_type + ROTATION_POSITIONS) % ROTATION_POSITIONS
	}
