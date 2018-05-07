extends Node

const I_BLOCK_TEXTURE = preload("res://Art/Tetrominos/IBlock.png")
const J_BLOCK_TEXTURE = preload("res://Art/Tetrominos/JBlock.png")
const L_BLOCK_TEXTURE = preload("res://Art/Tetrominos/LBlock.png")
const O_BLOCK_TEXTURE = preload("res://Art/Tetrominos/OBlock.png")
const S_BLOCK_TEXTURE = preload("res://Art/Tetrominos/SBlock.png")
const T_BLOCK_TEXTURE = preload("res://Art/Tetrominos/TBlock.png")
const Z_BLOCK_TEXTURE = preload("res://Art/Tetrominos/ZBlock.png")

enum GridValues { EMPTY, PIECE, INVALID, IBLOCK, JBLOCK, LBLOCK, OBLOCK, SBLOCK, TBLOCK, ZBLOCK }
enum RotationDirections { LEFT = -1, RIGHT = 1 }
enum PieceState { STANDBY, ACTIVE }

const TETROMINO_TYPES = [ IBLOCK, JBLOCK, LBLOCK, OBLOCK, SBLOCK, TBLOCK, ZBLOCK ]
const TETROMINO_TEXTURES = {
	IBLOCK: I_BLOCK_TEXTURE,
	JBLOCK: J_BLOCK_TEXTURE,
	LBLOCK: L_BLOCK_TEXTURE,
	OBLOCK: O_BLOCK_TEXTURE,
	SBLOCK: S_BLOCK_TEXTURE,
	TBLOCK: T_BLOCK_TEXTURE,
	ZBLOCK: Z_BLOCK_TEXTURE,
}
