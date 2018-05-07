extends Node

enum GridValues { EMPTY, PIECE, INVALID, IBLOCK, JBLOCK, LBLOCK, OBLOCK, SBLOCK, TBLOCK, ZBLOCK }
enum RotationDirections { LEFT = -1, RIGHT = 1 }

const tetromino_types = [ IBLOCK, JBLOCK, LBLOCK, OBLOCK, SBLOCK, TBLOCK, ZBLOCK ]
