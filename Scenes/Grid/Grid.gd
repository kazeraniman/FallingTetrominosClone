extends Node2D

var Utility = preload("res://Scripts/Utility.gd")
var GridCell = preload("res://Scenes/GridCell/GridCell.tscn")

var NUM_COLUMNS = 10
var NUM_ROWS = 20
var GRID_PAD = 2
var PADDED_NUM_COLUMNS = NUM_COLUMNS + GRID_PAD * 2
var PADDED_NUM_ROWS = NUM_ROWS + GRID_PAD * 2

var GRID_CELL_INITIAL_HORIZONTAL_OFFSET = -144
var GRID_CELL_INITIAL_VERTICAL_OFFSET = -304
var GRID_CELL_SIZE = 32

var grid_state = []
var grid_cells = []

func _ready():
	# Set the initial grid state
	for row in range(PADDED_NUM_ROWS):
		grid_state.append([])
		grid_state[row].resize(PADDED_NUM_COLUMNS)
		for column in range(PADDED_NUM_COLUMNS):
			if row > PADDED_NUM_ROWS - GRID_PAD - 1 or column < GRID_PAD or column > PADDED_NUM_COLUMNS - GRID_PAD - 1:
				grid_state[row][column] = Utility.INVALID
			else:
				grid_state[row][column] = Utility.EMPTY
	
	# Set up the display cells
	for row in range(NUM_ROWS):
		grid_cells.append([])
		grid_cells[row].resize(NUM_COLUMNS)
		for column in range(NUM_COLUMNS):
			var new_grid_cell = GridCell.instance()
			new_grid_cell.position = Vector2(GRID_CELL_INITIAL_HORIZONTAL_OFFSET + GRID_CELL_SIZE * column , GRID_CELL_INITIAL_VERTICAL_OFFSET + GRID_CELL_SIZE * row)
			grid_cells[row][column] = new_grid_cell
			add_child(new_grid_cell)
