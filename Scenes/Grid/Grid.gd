extends Node2D

signal lines_cleared(lines_cleared, clear_type)
signal next_tetromino(next_tetromino)
signal hold_tetromino(tetromino)
signal pause(paused)
signal game_over

var good_sound = preload("res://Audio/Sounds/good.wav")
var bad_sound = preload("res://Audio/Sounds/bad.wav")
var lose_sound = preload("res://Audio/Sounds/lose.wav")
var place_sound = preload("res://Audio/Sounds/place.wav")

var Utility = preload("res://Scripts/Utility.gd")
var GridCell = preload("res://Scenes/GridCell/GridCell.tscn")
var LineClearFlashiness = preload("res://Scenes/LineClearFlashiness/LineClearFlashiness.tscn")

enum GameState { PLAYING, NOT_PLAYING, PAUSED }
enum Movements { DOWN, LEFT, RIGHT }

const NUM_COLUMNS = 10
const NUM_ROWS = 20
const GRID_PAD = 2
const DOUBLE_GRID_PAD = GRID_PAD * 2
const PADDED_NUM_COLUMNS = NUM_COLUMNS + DOUBLE_GRID_PAD * 2
const PADDED_NUM_ROWS = NUM_ROWS + GRID_PAD * 3

const GRID_CELL_INITIAL_HORIZONTAL_OFFSET = -144
const GRID_CELL_INITIAL_VERTICAL_OFFSET = -304
const GRID_CELL_SIZE = 32
const HALF_GRID_CELL_SIZE = GRID_CELL_SIZE / 2
var SPAWN_POSITION = Vector2(DOUBLE_GRID_PAD + 3, GRID_PAD)

var EMPTY_ROW = []
var INVALID_ROW = []

var LEFT_VECTOR = Vector2(-1, 0)
var RIGHT_VECTOR = Vector2(1, 0)
var DOWN_VECTOR = Vector2(0, 1)

const VOLUMES = {
	"GOOD_SOUND": -25,
	"BAD_SOUND": -15,
	"LOSE_SOUND": -10,
	"PLACE_SOUND": -20
}

const INITIAL_GRAVITY_COUNTER = 60
const LEVEL_SPEEDUP_FACTOR = 2
var gravity_counter = INITIAL_GRAVITY_COUNTER
var gravity_tick = gravity_counter

const KEY_REPEAT_INITIAL = 25
const KEY_REPEAT_ADDITIONAL = 5
var key_repeat = {
	Movements.DOWN: KEY_REPEAT_INITIAL,
	Movements.LEFT: KEY_REPEAT_INITIAL,
	Movements.RIGHT: KEY_REPEAT_INITIAL
}

const LEVEL_UPWARD_WALL_KICK_LIMIT = 7
var upward_wall_kick_state = {
	"lowest_row": 0,
	"count": 0
}

var grid_state = []
var grid_cells = []
var line_clear_flashiness_elements = []
var active_tetromino = null
var active_tetromino_top_left_anchor
var ghost_tetromino_top_left_anchor
var current_piece_state = Utility.STANDBY
var held_tetromino = null
var recently_held = false
var current_game_state = GameState.NOT_PLAYING
var last_action_was_rotation = false

func _ready():
	# Set up the empty row
	EMPTY_ROW.resize(PADDED_NUM_COLUMNS)
	for column in range(PADDED_NUM_COLUMNS):
		if column >= DOUBLE_GRID_PAD and column < PADDED_NUM_COLUMNS - DOUBLE_GRID_PAD:
			EMPTY_ROW[column] = Utility.EMPTY
		else:
			EMPTY_ROW[column] = Utility.INVALID

	# Set up the invalid row
	INVALID_ROW.resize(PADDED_NUM_COLUMNS)
	for column in range(PADDED_NUM_COLUMNS):
		INVALID_ROW[column] = Utility.INVALID

	# Set the initial grid state
	grid_state.resize(PADDED_NUM_ROWS)
	clear_grid()

	# Set up the display cells
	for row in range(NUM_ROWS):
		grid_cells.append([])
		grid_cells[row].resize(NUM_COLUMNS)
		for column in range(NUM_COLUMNS):
			var new_grid_cell = GridCell.instance()
			new_grid_cell.position = Vector2(GRID_CELL_INITIAL_HORIZONTAL_OFFSET + GRID_CELL_SIZE * column , GRID_CELL_INITIAL_VERTICAL_OFFSET + GRID_CELL_SIZE * row)
			grid_cells[row][column] = new_grid_cell
			add_child(new_grid_cell)

	# Set up the line clear flashiness
	line_clear_flashiness_elements.resize(NUM_ROWS)
	for row in range(NUM_ROWS):
		var line_clear_flashiness_element = LineClearFlashiness.instance()
		line_clear_flashiness_element.position = Vector2(GRID_CELL_INITIAL_HORIZONTAL_OFFSET - HALF_GRID_CELL_SIZE, GRID_CELL_INITIAL_VERTICAL_OFFSET + GRID_CELL_SIZE * row - HALF_GRID_CELL_SIZE)
		line_clear_flashiness_elements[row] = line_clear_flashiness_element
		add_child(line_clear_flashiness_element)

	start_game()

func _process(delta):
	draw_grid_cells()
	draw_ghost_tetromino()
	draw_active_tetromino()

func _physics_process(delta):
	# Pause is special and needs to be checked more often
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	# Key release should also be taken into consideration whether we're paused or not
	if Input.is_action_just_released("move_down"):
		key_repeat[Movements.DOWN] = KEY_REPEAT_INITIAL
	if Input.is_action_just_released("move_left"):
		key_repeat[Movements.LEFT] = KEY_REPEAT_INITIAL
	if Input.is_action_just_released("move_right"):
		key_repeat[Movements.RIGHT] = KEY_REPEAT_INITIAL
	# Only do work if we are currently playing
	if current_game_state == GameState.PLAYING:
		# Flag to check if the ghost piece should be moved
		var move_ghost_piece = false
		# Apply gravity if the time has come
		gravity_tick -= 1
		if gravity_tick <= 0:
			apply_gravity()
			gravity_tick = gravity_counter
		# Only applies control if the piece is ready
		if current_piece_state == Utility.ACTIVE:
			# Movements
			if Input.is_action_just_pressed("move_down"):
				move_tetromino(Movements.DOWN)
			if Input.is_action_just_pressed("move_left"):
				move_ghost_piece = move_ghost_piece or move_tetromino(Movements.LEFT)
			if Input.is_action_just_pressed("move_right"):
				move_ghost_piece = move_ghost_piece or move_tetromino(Movements.RIGHT)
			# Repeated movements for held-down keys
			if Input.is_action_pressed("move_down"):
				repeated_movement(Movements.DOWN)
			if Input.is_action_pressed("move_left"):
				move_ghost_piece = move_ghost_piece or repeated_movement(Movements.LEFT)
			if Input.is_action_pressed("move_right"):
				move_ghost_piece = move_ghost_piece or repeated_movement(Movements.RIGHT)
			# Rotations
			if Input.is_action_just_pressed("rotate_right"):
				if(try_rotate(Utility.RIGHT)):
					last_action_was_rotation = true
					move_ghost_piece = true
			if Input.is_action_just_pressed("rotate_left"):
				if(try_rotate(Utility.LEFT)):
					last_action_was_rotation = true
					move_ghost_piece = true
			# Special
			if Input.is_action_just_pressed("hard_drop"):
				hard_drop()
			if Input.is_action_just_pressed("hold_piece"):
				hold_tetromino()

		# Move the ghost piece if necessary
		if move_ghost_piece:
			determine_ghost_tetromino_placement()

func move_tetromino(direction):
	"""
	Perform the attempted move of the tetromino in the given direction.
	:param direction: The direction of the move to be attempted.
	:type direction: Movements.
	:return: True if the movement was successful, false otherwise.
	:rtype: Boolean.
	"""
	match direction:
		Movements.DOWN:
			var moved_down = try_move(DOWN_VECTOR, false, true)
			# If the user successfully moved down, reset the gravity tick to avoid movements down in quick succession
			if moved_down:
				last_action_was_rotation = false
				gravity_tick = gravity_counter
				return true
		Movements.LEFT:
			if(try_move(LEFT_VECTOR)):
				last_action_was_rotation = false
				return true
		Movements.RIGHT:
			if(try_move(RIGHT_VECTOR)):
				last_action_was_rotation = false
				return true
	return false

func repeated_movement(direction):
	"""
	Check whether a key has been held sufficiently long to repeat the move and perform the move if so.
	:param direction: The direction of the move to be attempted.
	:type direction: Movements.
	:return: True if the movement occurred, false otherwise.
	:rtype: Boolean.
	"""
	key_repeat[direction] -= 1
	if key_repeat[direction] <= 0:
		key_repeat[direction] = KEY_REPEAT_ADDITIONAL
		if move_tetromino(direction):
			return true
	return false

func clear_grid():
	"""
	Wipes the grid state.
	"""
	for row in range(PADDED_NUM_ROWS):
		if row >= GRID_PAD and row < PADDED_NUM_ROWS - GRID_PAD:
			grid_state[row] = EMPTY_ROW.duplicate()
		else:
			grid_state[row] = INVALID_ROW.duplicate()

func draw_grid_cells():
	"""
	Updates the textures for all of the grid cells.
	"""
	for row in range(PADDED_NUM_ROWS):
		for column in range(PADDED_NUM_COLUMNS):
			# Only draw for valid cells
			if row >= DOUBLE_GRID_PAD and row < PADDED_NUM_ROWS - GRID_PAD and column >= DOUBLE_GRID_PAD and column < PADDED_NUM_COLUMNS - DOUBLE_GRID_PAD:
				grid_cells[row - DOUBLE_GRID_PAD][column - DOUBLE_GRID_PAD].set_cell_type(grid_state[row][column])

func draw_active_tetromino():
	"""
	Updates the textures for the active piece.
	"""
	for row in range(active_tetromino.piece_matrix.size()):
		for column in range(active_tetromino.piece_matrix.size()):
			if active_tetromino.piece_matrix[row][column] == Utility.PIECE:
				# Only draw for valid cells
				var cell_to_draw = Vector2(column + active_tetromino_top_left_anchor.x, row + active_tetromino_top_left_anchor.y)
				if cell_to_draw.y >= DOUBLE_GRID_PAD and cell_to_draw.y < PADDED_NUM_ROWS - GRID_PAD and cell_to_draw.x >= DOUBLE_GRID_PAD and cell_to_draw.x < PADDED_NUM_COLUMNS - DOUBLE_GRID_PAD:
					grid_cells[cell_to_draw.y - DOUBLE_GRID_PAD][cell_to_draw.x - DOUBLE_GRID_PAD].set_cell_type(active_tetromino.piece_type)

func determine_ghost_tetromino_placement():
	"""
	Figures out where to draw the ghost tetromino in order to give a clearer idea of where the piece will end up.
	"""
	ghost_tetromino_top_left_anchor = active_tetromino_top_left_anchor
	while(check_valid_piece_state(active_tetromino.piece_matrix, ghost_tetromino_top_left_anchor + DOWN_VECTOR)):
		ghost_tetromino_top_left_anchor += DOWN_VECTOR

func draw_ghost_tetromino():
	"""
	Updates the textures for the ghost piece.
	"""
	for row in range(active_tetromino.piece_matrix.size()):
		for column in range(active_tetromino.piece_matrix.size()):
			if active_tetromino.piece_matrix[row][column] == Utility.PIECE:
				# Only draw for valid cells
				var cell_to_draw = Vector2(column + ghost_tetromino_top_left_anchor.x, row + ghost_tetromino_top_left_anchor.y)
				if cell_to_draw.y >= DOUBLE_GRID_PAD and cell_to_draw.y < PADDED_NUM_ROWS - GRID_PAD and cell_to_draw.x >= DOUBLE_GRID_PAD and cell_to_draw.x < PADDED_NUM_COLUMNS - DOUBLE_GRID_PAD:
					grid_cells[cell_to_draw.y - DOUBLE_GRID_PAD][cell_to_draw.x - DOUBLE_GRID_PAD].set_cell_type(Utility.GHOST)

func start_game():
	"""
	Starts the actual game logic.
	"""
	# Create the first tetromino
	create_new_tetromino()
	# Allow the user to interact
	current_piece_state = Utility.ACTIVE
	current_game_state = GameState.PLAYING

func restart_game():
	"""
	Performs the necessary re-initialization to play another game.
	"""
	# Stop all sound effects
	$SoundEffectsPlayer.stop()
	# Wipe the grid
	clear_grid()
	# Reset the necessary variables
	gravity_counter = INITIAL_GRAVITY_COUNTER
	gravity_tick = gravity_counter
	active_tetromino = null
	held_tetromino = null
	recently_held = false
	key_repeat = {
		Movements.DOWN: KEY_REPEAT_INITIAL,
		Movements.LEFT: KEY_REPEAT_INITIAL,
		Movements.RIGHT: KEY_REPEAT_INITIAL
	}
	last_action_was_rotation = false
	upward_wall_kick_state = {
		"lowest_row": 0,
		"count": 0
	}
	# Redraw the grid
	draw_grid_cells()
	# Choose the next tetromino so it won't start with the next piece from the last game
	$TetrominoSpawner.reset_next_tetromino()
	# Start the game
	start_game()

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

func try_move(desired_move, override_check=false, mute=false):
	"""
	Try to move the active piece in the desired direction.  Perform the move if it is successful.
	:param desired_move: The direction in which the move is intended along both axes.
	:param override_check: Override checking that the piece will be valid in the destination.  Only for use if checking has been done elsewhere to
	avoid repeated work.
	:param mute: Whether or not to play the sound effects.
	:type desired_move: Vector2.
	:type override_check: Boolean.
	:type mute: Boolean.
	:return: True if the move is successful, false otherwise.
	:rtype: Boolean.
	"""
	# Try the move out by generating the associated position
	var attempted_move_top_left_anchor = active_tetromino_top_left_anchor + desired_move

	# If the move causes no overlap, perform it
	if override_check or check_valid_piece_state(active_tetromino.piece_matrix, attempted_move_top_left_anchor):
		active_tetromino_top_left_anchor = attempted_move_top_left_anchor
		if !mute:
			play_sound_effect(good_sound, VOLUMES["GOOD_SOUND"])
		return true
	# Otherwise reject the move
	else:
		if !mute:
			play_sound_effect(bad_sound, VOLUMES["BAD_SOUND"])
		return false

func try_rotate(rotation_direction):
	"""
	Try to rotate the active piece in the desired direction.  If a standard rotation is not possible, a number of wall-kicks are attempted before giving up.
	:param rotation_direction: The direction in which the rotation is intended to occur.
	:type rotation_direction: RotationDirections.
	:return: True if the rotation was successful, false otherwise.
	:rtype: Boolean.
	"""
	# We don't rotate OBlocks, so just abort if the current block is one
	if active_tetromino.piece_type == Utility.OBLOCK:
		return false

	var theoretical_rotation = active_tetromino.theoretical_rotate(rotation_direction)
	# If a standard rotation is possible, apply it
	if check_valid_piece_state(theoretical_rotation["new_piece_matrix"], active_tetromino_top_left_anchor):
		active_tetromino.apply_rotation(theoretical_rotation)
		play_sound_effect(good_sound, VOLUMES["GOOD_SOUND"])
		return true
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
			# If the wall-kick moves us upward it is potentially of concern to avoid infinite scenarios
			if wall_kick.y < 0:
				# If we've dropped down lower than we've been before, reset the wall-kick state
				if active_tetromino_top_left_anchor.y > upward_wall_kick_state["lowest_row"]:
					upward_wall_kick_state = {
						"lowest_row": active_tetromino_top_left_anchor.y,
						"count": 0
					}
				# If we've reached the limit for upward wall-kicks at this level, ignore this wall-kick
				elif upward_wall_kick_state["count"] >= LEVEL_UPWARD_WALL_KICK_LIMIT:
					continue
			if check_valid_piece_state(theoretical_rotation["new_piece_matrix"], active_tetromino_top_left_anchor + wall_kick):
				# If an upward wall kick will be allowed, increment the count
				if wall_kick.y < 0:
					upward_wall_kick_state["count"] += 1
				# Apply the wall-kick
				active_tetromino.apply_rotation(theoretical_rotation)
				try_move(wall_kick, true)
				play_sound_effect(good_sound, VOLUMES["GOOD_SOUND"])
				return true

	play_sound_effect(bad_sound, VOLUMES["BAD_SOUND"])
	return false

func create_new_tetromino(specific_tetromino_type=null):
	"""
	Create a new tetromino at the spawn position.  If a tetromino is specified, creates that tetromino.
	:param specific_tetromino_type: (Optional) The type of tetromino to generate.
	:type specific_tetromino_type: GridValues.
	"""
	# Free the last tetromino if there was one
	if active_tetromino:
		active_tetromino.queue_free()
	# Create a new tetromino
	active_tetromino = $TetrominoSpawner.generate_tetromino(specific_tetromino_type)
	# Set the spawn position as the current position
	active_tetromino_top_left_anchor = SPAWN_POSITION
	# Reset the gravity tick
	gravity_tick = gravity_counter
	# Reset the last movement
	last_action_was_rotation = false
	# Add the tetromino to the tree
	add_child(active_tetromino)
	# Figure out where to put the ghost piece
	determine_ghost_tetromino_placement()

func apply_active_tetromino():
	"""
	Takes the active tetromino and applies it to the game state for permanence, then generates the next piece.
	"""
	# Prevent user interaction while applying
	current_piece_state = Utility.STANDBY
	# Apply the piece to the grid state
	for row in range(active_tetromino.piece_matrix.size()):
		for column in range(active_tetromino.piece_matrix.size()):
			if active_tetromino.piece_matrix[row][column] == Utility.PIECE:
				var cell_to_apply = Vector2(column + active_tetromino_top_left_anchor.x, row + active_tetromino_top_left_anchor.y)
				grid_state[cell_to_apply.y][cell_to_apply.x] = active_tetromino.piece_type
	play_sound_effect(place_sound, VOLUMES["PLACE_SOUND"])
	# Clear any filled rows
	clear_lines()
	# Check if the game is over
	var game_over = detect_game_over()
	if !game_over:
		# Generate the next tetromino
		create_new_tetromino()
		# A piece was placed so the user should be allowed to hold a piece again
		recently_held = false
		# Update the wall-kick state
		upward_wall_kick_state = {
			"lowest_row": 0,
			"count": 0
		}
		# Re-activate user interaction
		current_piece_state = Utility.ACTIVE

func clear_lines():
	"""
	Clear all completed lines and appropriately re-arrange the board to account for any cleared rows.
	"""
	# Keep track of number of cleared lines in order to appropriately shift the lines above
	var shift_counter = 0
	# Keep track of the cleared lines to show flashiness
	var cleared_lines = []
	# Keep track of whether a T-Spin occurred
	var did_tspin = false
	# Iterate over the rows starting from the bottom
	for row in range(PADDED_NUM_ROWS - GRID_PAD - 1, DOUBLE_GRID_PAD - 1, -1):
		var all_columns_filled = true
		for column in range(DOUBLE_GRID_PAD, PADDED_NUM_COLUMNS - DOUBLE_GRID_PAD):
			# Empty slots mean the row isn't filled
			if grid_state[row][column] == Utility.EMPTY:
				all_columns_filled = false
				break
		# If the row was filled, increment the cleared line count and clear the row
		if all_columns_filled:
			did_tspin = did_tspin or detect_tspin()
			shift_counter += 1
			cleared_lines.append(row - DOUBLE_GRID_PAD)
			grid_state[row] = EMPTY_ROW.duplicate()
		else:
			# Only shift lines if lines have been cleared
			if shift_counter > 0:
				grid_state[row + shift_counter] = grid_state[row].duplicate()
				grid_state[row] = EMPTY_ROW.duplicate()
	# Show the flashiness for rows which were cleared
	for line in cleared_lines:
		line_clear_flashiness_elements[line].play_line_clear()
	# Notify that lines were cleared
	if shift_counter > 0:
		$ClearLineSoundEffectPlayer.play()
		emit_signal("lines_cleared", shift_counter, Utility.REGULAR if !did_tspin else Utility.TSPIN)

func detect_tspin():
	"""
	Detects whether a T-Spin has occurred.
	There are 3 criteria which must be satisfied:
		1) The active piece must be a T-Block.
		2) The last movement must have been a rotation.  Gravity does not count as a movement but regular downward movement does.
		3) 3 of the 4 corners of the 3x3 piece matrix must be occupied.
	:return: True if a T-Spin occurred, false otherwise.
	:rtype: Boolean.
	"""
	# Criteria 1 check
	if active_tetromino.piece_type != Utility.TBLOCK:
		return false
	# Criteria 2 check
	if !last_action_was_rotation:
		return false
	# Criteria 3 check
	var corner_count = 0
	# Top-left corner
	if grid_state[active_tetromino_top_left_anchor.y][active_tetromino_top_left_anchor.x] != Utility.EMPTY and \
		grid_state[active_tetromino_top_left_anchor.y][active_tetromino_top_left_anchor.x] != Utility.INVALID:
		corner_count += 1
	# Top-right corner
	if grid_state[active_tetromino_top_left_anchor.y][active_tetromino_top_left_anchor.x + 2] != Utility.EMPTY and \
		grid_state[active_tetromino_top_left_anchor.y][active_tetromino_top_left_anchor.x + 2] != Utility.INVALID:
		corner_count += 1
	# Bottom-left corner
	if grid_state[active_tetromino_top_left_anchor.y + 2][active_tetromino_top_left_anchor.x] != Utility.EMPTY and \
		grid_state[active_tetromino_top_left_anchor.y + 2][active_tetromino_top_left_anchor.x] != Utility.INVALID:
		corner_count += 1
	# Bottom-right corner
	if grid_state[active_tetromino_top_left_anchor.y + 2][active_tetromino_top_left_anchor.x + 2] != Utility.EMPTY and \
		grid_state[active_tetromino_top_left_anchor.y + 2][active_tetromino_top_left_anchor.x + 2] != Utility.INVALID:
		corner_count += 1
	return corner_count >= 3

func apply_gravity():
	"""
	Attempt to apply gravity to the tetromino, either moving the piece down or realizing that piece may not be dropped lower and applying
	it to the grid state.
	"""
	# Disable user interaction during gravity
	current_piece_state = Utility.STANDBY
	# If the gravity didn't manage to move the tetromino, it must be stuck so embed the piece
	var gravity_successful = try_move(DOWN_VECTOR, false, true)
	if !gravity_successful:
		apply_active_tetromino()
	# If gravity worked out, restore player control
	else:
		current_piece_state = Utility.ACTIVE

func hard_drop():
	"""
	Drop the current tetromino down as far as it will go.
	"""
	# Disable user interaction during gravity
	current_piece_state = Utility.STANDBY
	# Repeatedly drop the piece by one row until it fails
	while(try_move(DOWN_VECTOR, false, true)):
		pass
	# Set the last movement as not a rotation
	last_action_was_rotation = false
	# Apply the piece to the grid state
	apply_active_tetromino()

func hold_tetromino():
	"""
	Takes the current piece and swaps it to the hold storage, bringing out a new piece if the hold was empty or swapping in the last held piece
	otherwise.  Prevents a user from swapping infinitely, requiring a piece to have been placed between holds.
	"""
	# Shouldn't allow the player to repeatedly swap pieces to think
	if recently_held:
		return
	recently_held = true

	# If we have previously held a block, swap it in
	if held_tetromino != null:
		var previously_held_tetromino = held_tetromino
		held_tetromino = active_tetromino.piece_type
		create_new_tetromino(previously_held_tetromino)
	# Otherwise just stow away the current block and create the next one
	else:
		held_tetromino = active_tetromino.piece_type
		create_new_tetromino()

	# Signal that a new piece was held
	emit_signal("hold_tetromino", held_tetromino)

func detect_game_over():
	"""
	Determines whether the game should end based on where the active piece is currently.
	:return: True if the game should end, false otherwise.
	:rtype: Boolean.
	"""
	for row in range(active_tetromino.piece_matrix.size()):
		for column in range(active_tetromino.piece_matrix.size()):
			if active_tetromino.piece_matrix[row][column] == Utility.PIECE:
				# If any piece is above the playing grid, the player has failed to play the tetromino and the game is over
				if row + active_tetromino_top_left_anchor.y < DOUBLE_GRID_PAD:
					current_game_state = GameState.NOT_PLAYING
					current_piece_state = Utility.STANDBY
					play_sound_effect(lose_sound, VOLUMES["LOSE_SOUND"])
					emit_signal("game_over")
					return true
	return false

func toggle_pause():
	"""
	Pause / unpause the game if possible.  Do nothing if we aren't in a game.
	"""
	# Pause the game if we're playing
	if current_game_state == GameState.PLAYING:
		current_game_state = GameState.PAUSED
		emit_signal("pause", true)
	# Unpause the game if we're paused
	elif current_game_state == GameState.PAUSED:
		current_game_state = GameState.PLAYING
		emit_signal("pause", false)

func play_sound_effect(sound_effect, volume=0):
	"""
	Plays the provided sound effect.
	:param sound_effect: The sound effect to play.
	:param volume: The volume at which to play the sound effect.
	:type sound_effect: Preloaded sound effect.
	:type volume: Int.
	"""
	$SoundEffectsPlayer.stop()
	$SoundEffectsPlayer.volume_db = volume
	$SoundEffectsPlayer.stream = sound_effect
	$SoundEffectsPlayer.play()

func level_up():
	"""
	Speed up the game to increase the challenge.
	"""
	gravity_counter -= LEVEL_SPEEDUP_FACTOR

func _on_TetrominoSpawner_next_tetromino(next_tetromino):
	emit_signal("next_tetromino", next_tetromino)
