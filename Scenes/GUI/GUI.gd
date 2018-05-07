extends CanvasLayer

var Utility = preload("res://Scripts/Utility.gd")

var IBlock = preload("res://Art/Tetrominos/IBlock.png")
var JBlock = preload("res://Art/Tetrominos/JBlock.png")
var LBlock = preload("res://Art/Tetrominos/LBlock.png")
var OBlock = preload("res://Art/Tetrominos/OBlock.png")
var SBlock = preload("res://Art/Tetrominos/SBlock.png")
var TBlock = preload("res://Art/Tetrominos/TBlock.png")
var ZBlock = preload("res://Art/Tetrominos/ZBlock.png")

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
	Set's the texture of next block on the GUI to the block image matching the input.
	:param next_block: The block type to be displayed.
	:type next_block: GridValues.
	"""
	match next_block:
		Utility.EMPTY:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = null
		Utility.IBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = IBlock
		Utility.JBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = JBlock
		Utility.LBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = LBlock
		Utility.OBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = OBlock
		Utility.SBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = SBlock
		Utility.TBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = TBlock
		Utility.ZBLOCK:
			$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = ZBlock
