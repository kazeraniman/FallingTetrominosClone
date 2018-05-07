extends CanvasLayer

var Utility = preload("res://Scripts/Utility.gd")

func set_score(score):
	"""
	Sets the score on the GUI to the provided value.
	:param score: The score to set.
	:type score: Int.
	"""
	$StatsPanel/VBoxContainer/ScoreLabel.text = str(score)

func set_cleared_lines(cleared_lines):
	"""
	Sets the lines cleared on the GUI to the provided value.
	:param score: The lines cleared to set.
	:type score: Int.
	"""
	$StatsPanel/VBoxContainer/LinesClearedLabel.text = str(cleared_lines)

func set_next_block(next_block):
	"""
	Sets the texture of next block on the GUI to the block image matching the input.
	:param next_block: The block type to be displayed.
	:type next_block: GridValues.
	"""
	$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = Utility.TETROMINO_TEXTURES[next_block]

func set_hold_block(held_block):
	"""
	Sets the texture of held block on the GUI to the block image matching the input.
	:param held_block: The block type to be displayed.
	:type held_block: GridValues.
	"""
	$HeldTetrominoPanel/VBoxContainer/HeldTetrominoImage.texture = Utility.TETROMINO_TEXTURES[held_block]
