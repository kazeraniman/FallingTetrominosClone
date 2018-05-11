extends Node2D

var Utility = preload("res://Scripts/Utility.gd")

# Preload all the textures so we don't tax the system later
const RED_CELL_TEXTURE = preload("res://Art/Tetrominos/element_red_square.png")
const ORANGE_CELL_TEXTURE = preload("res://Art/Tetrominos/element_orange_square.png")
const YELLOW_CELL_TEXTURE = preload("res://Art/Tetrominos/element_yellow_square.png")
const GREEN_CELL_TEXTURE = preload("res://Art/Tetrominos/element_green_square.png")
const BLUE_CELL_TEXTURE = preload("res://Art/Tetrominos/element_blue_square.png")
const PURPLE_CELL_TEXTURE = preload("res://Art/Tetrominos/element_purple_square.png")
const VIOLET_CELL_TEXTURE = preload("res://Art/Tetrominos/element_violet_square.png")
const GHOST_CELL_TEXTURE = preload("res://Art/Tetrominos/element_ghost_square.png")

var CELL_TEXTURES = {
	Utility.IBLOCK: RED_CELL_TEXTURE,
	Utility.JBLOCK: PURPLE_CELL_TEXTURE,
	Utility.LBLOCK: YELLOW_CELL_TEXTURE,
	Utility.OBLOCK: GREEN_CELL_TEXTURE,
	Utility.SBLOCK: BLUE_CELL_TEXTURE,
	Utility.TBLOCK: ORANGE_CELL_TEXTURE,
	Utility.ZBLOCK: VIOLET_CELL_TEXTURE,
	Utility.GHOST: GHOST_CELL_TEXTURE
}

func set_cell_type(cell_type):
	"""
	Set's the texture of the grid cell to the block type matching the input.
	:param cell_type: The block type to be displayed.
	:type cell_type: GridValues.
	"""
	if cell_type == Utility.EMPTY:
		$Sprite.set_texture(null)
	else:
		$Sprite.set_texture(CELL_TEXTURES[cell_type])
