extends Node2D

enum GridValues { EMPTY, INVALID, IBLOCK, JBLOCK, LBLOCK, OBLOCK, SBLOCK, TBLOCK, ZBLOCK }

var NUM_COLUMNS = 10
var NUM_ROWS = 20
var GRID_PAD = 2
var PADDED_NUM_COLUMNS = NUM_COLUMNS + GRID_PAD * 2
var PADDED_NUM_ROWS = NUM_ROWS + GRID_PAD * 2

var grid_state = []

func _ready():
	# Set the initial grid state
	for row in range(PADDED_NUM_ROWS):
		grid_state.append([])
		grid_state[row].resize(PADDED_NUM_COLUMNS)
		for column in range(PADDED_NUM_COLUMNS):
			if row > PADDED_NUM_ROWS - GRID_PAD - 1 or column < GRID_PAD or column > PADDED_NUM_COLUMNS - GRID_PAD - 1:
				grid_state[row][column] = INVALID
			else:
				grid_state[row][column] = EMPTY
