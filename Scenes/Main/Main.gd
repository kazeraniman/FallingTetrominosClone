extends Node2D

var BASE_LINE_SCORE = 10
var EXTRA_LINE_MULTIPLIER = 2
var MAX_SCORE_LINES = 99999999999

var score = 0
var total_lines_cleared = 0

func _init():
	randomize()

func _on_Grid_lines_cleared(lines_cleared):
	total_lines_cleared += lines_cleared
	clamp(total_lines_cleared, 0, MAX_SCORE_LINES)
	score += BASE_LINE_SCORE * int(pow(EXTRA_LINE_MULTIPLIER, lines_cleared - 1))
	clamp(score, 0, MAX_SCORE_LINES)
	$GUI.set_score(score)
	$GUI.set_cleared_lines(total_lines_cleared)
