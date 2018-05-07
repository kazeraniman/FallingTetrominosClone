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
var active_tetromino

# CHANGE THIS
var active_piece_top_left_anchor = Vector2(GRID_PAD, GRID_PAD + 1)

func _ready():
	# TODO: Move this to the main node when it's created.
	randomize()

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

	active_tetromino = $TetrominoSpawner.generate_tetromino()
	add_child(active_tetromino)

func _process(delta):
	# Update the textures for all of the grid cells
	for row in range(PADDED_NUM_ROWS):
		for column in range(PADDED_NUM_COLUMNS):
			# Only draw for valid cells
			if row >= GRID_PAD and row < PADDED_NUM_ROWS - GRID_PAD and column >= GRID_PAD and column < PADDED_NUM_COLUMNS - GRID_PAD:
				grid_cells[row - GRID_PAD][column - GRID_PAD].set_cell_type(grid_state[row][column])

	# Update the textures for the active piece
	for row in range(active_tetromino.piece_matrix.size()):
		for column in range(active_tetromino.piece_matrix.size()):
			if active_tetromino.piece_matrix[row][column] == Utility.PIECE:
				# Only draw for valid cells
				var cell_to_draw = Vector2(column + active_piece_top_left_anchor.x, row + active_piece_top_left_anchor.y)
				if cell_to_draw.y >= GRID_PAD and cell_to_draw.y < PADDED_NUM_ROWS - GRID_PAD and cell_to_draw.x >= GRID_PAD and cell_to_draw.x < PADDED_NUM_COLUMNS - GRID_PAD:
					grid_cells[cell_to_draw.y - GRID_PAD][cell_to_draw.x - GRID_PAD].set_cell_type(active_tetromino.piece_type)

func _physics_process(delta):
	if Input.is_action_just_pressed("move_down"):
		try_move(Vector2(0, 1))
	# UP IS ONLY FOR TESTING PURPOSES, SHOULD BE REMOVED LATER
	if Input.is_action_just_pressed("move_up"):
		try_move(Vector2(0, -1))
	if Input.is_action_just_pressed("move_left"):
		try_move(Vector2(-1, 0))
	if Input.is_action_just_pressed("move_right"):
		try_move(Vector2(1, 0))

	if Input.is_action_just_pressed("rotate_right"):
		try_rotate(Utility.RIGHT)
	if Input.is_action_just_pressed("rotate_left"):
		try_rotate(Utility.LEFT)

func check_valid_piece_state(piece_matrix, top_left_anchor):
	"""
	Determines whether the provided piece state is acceptable or not.
	:param piece_matrix: The state of empty and piece cells for the tetromino.
	:param top_left_anchor: The position of the top-left cell of the piece matrix.
	:type piece_matrix: 2D Array of GridValues.
	:type top_left_anchor: Vector2.
	:return: True if the piece state is valid, false otherwise.
	:rtype: Boolean.
	"""
	# Check the piece positions to ensure that there is no overlap at any point
	for row in range(piece_matrix.size()):
		for column in range(piece_matrix.size()):
			if piece_matrix[row][column] == Utility.PIECE:
				# There's an overlap with a non-empty cell so reject the move
				if grid_state[row + top_left_anchor.y][column + top_left_anchor.x] != Utility.EMPTY:
					return false
	# No overlaps found, the move should be safe
	return true

func try_move(desired_move, override_check=false):
	"""
	Try to move the active piece in the desired direction.
	:param desired_move: The direction in which the move is intended along both axes.
	:param override_check: Override checking that the piece will be valid in the destination.  Only for use if checking has been done elsewhere to
	avoid repeated work.
	:type desired_move: Vector2.
	:type override_check: Boolean.
	:return: True if the move is successful, false otherwise.
	:rtype: Boolean.
	"""
	# Try the move out by generating the associated position
	var attempted_move_top_left_anchor = active_piece_top_left_anchor + desired_move

	# If the move causes no overlap, perform it
	if override_check or check_valid_piece_state(active_tetromino.piece_matrix, attempted_move_top_left_anchor):
		active_piece_top_left_anchor = attempted_move_top_left_anchor
		return true
	# Otherwise reject the move
	else:
		return false

func try_rotate(rotation_direction):
	"""
	Try to rotate the active piece in the desired direction.  If a standard rotation is not possible, a number of wall-kicks are attempted before giving up.
	:param rotation_direction: The direction in which the rotation is intended to occur.
	:type rotation_direction: RotationDirections.
	"""
	# We don't rotate OBlocks, so just abort if the current block is one
	if active_tetromino.piece_type == Utility.OBLOCK:
		return

	var theoretical_rotation = active_tetromino.theoretical_rotate(rotation_direction)
	# If a standard rotation is possible, apply it
	if check_valid_piece_state(theoretical_rotation["new_piece_matrix"], active_piece_top_left_anchor):
		active_tetromino.apply_rotation(theoretical_rotation)
	# Otherwise, we'll try the wall-kicks
	else:
		# Pick the right set of wall-kicks
		var wall_kicks
		if active_tetromino.piece_type == Utility.IBLOCK:
			wall_kicks = active_tetromino.I_WALL_KICKS
		else:
			wall_kicks = active_tetromino.MAIN_WALL_KICKS

		# Go through the wall-kicks in preference order and complete the first one possible
		for wall_kick in wall_kicks[active_tetromino.current_rotation_position][theoretical_rotation["new_rotation_position"]]:
			if check_valid_piece_state(theoretical_rotation["new_piece_matrix"], active_piece_top_left_anchor + wall_kick):
				active_tetromino.apply_rotation(theoretical_rotation)
				try_move(wall_kick, true)
				return
