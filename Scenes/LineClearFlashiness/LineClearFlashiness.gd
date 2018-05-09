extends Node2D

func play_line_clear():
	"""
	Plays the respective animations to spice up line clears visually.
	"""
	$AnimationPlayer.play("cleared_line")
