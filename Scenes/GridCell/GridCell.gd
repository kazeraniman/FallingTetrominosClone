extends Node2D

var Utility = preload("res://Scripts/Utility.gd")

# Preload all the textures so we don't tax the system later
var red_cell_texture = preload("res://Art/Tetrominos/element_red_square.png")
var orange_cell_texture = preload("res://Art/Tetrominos/element_orange_square.png")
var yellow_cell_texture = preload("res://Art/Tetrominos/element_yellow_square.png")
var green_cell_texture = preload("res://Art/Tetrominos/element_green_square.png")
var blue_cell_texture = preload("res://Art/Tetrominos/element_blue_square.png")
var purple_cell_texture = preload("res://Art/Tetrominos/element_purple_square.png")
var violet_cell_texture = preload("res://Art/Tetrominos/element_violet_square.png")

func set_cell_type(cell_type):
	match cell_type:
		Utility.EMPTY:
			$Sprite.set_texture(null)
		Utility.IBLOCK:
			$Sprite.set_texture(red_cell_texture)
		Utility.JBLOCK:
			$Sprite.set_texture(orange_cell_texture)
		Utility.LBLOCK:
			$Sprite.set_texture(yellow_cell_texture)
		Utility.OBLOCK:
			$Sprite.set_texture(green_cell_texture)
		Utility.SBLOCK:
			$Sprite.set_texture(blue_cell_texture)
		Utility.TBLOCK:
			$Sprite.set_texture(purple_cell_texture)
		Utility.ZBLOCK:
			$Sprite.set_texture(violet_cell_texture)
