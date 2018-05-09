extends Node2D

var bgm = [preload("res://Audio/Music/bgm1.wav"), preload("res://Audio/Music/bgm2.wav")]

var BASE_LINE_SCORE = 10
var EXTRA_LINE_MULTIPLIER = 2
var MAX_SCORE_LINES = 99999999999

var score = 0
var total_lines_cleared = 0
var paused_music_position

func _init():
	randomize()

func _ready():
	play_bgm()

func play_bgm():
	"""
	Play a random background song.
	"""
	$BackgroundMusicPlayer.stop()
	$BackgroundMusicPlayer.stream = bgm[randi() % bgm.size()]
	$BackgroundMusicPlayer.play()

func _on_Grid_lines_cleared(lines_cleared):
	total_lines_cleared += lines_cleared
	clamp(total_lines_cleared, 0, MAX_SCORE_LINES)
	score += BASE_LINE_SCORE * int(pow(EXTRA_LINE_MULTIPLIER, lines_cleared - 1))
	clamp(score, 0, MAX_SCORE_LINES)
	$GUI.set_score(score)
	$GUI.set_cleared_lines(total_lines_cleared)

func _on_Grid_next_tetromino(next_tetromino):
	$GUI.set_next_block(next_tetromino)

func _on_Grid_hold_tetromino(tetromino):
	$GUI.set_hold_block(tetromino)

func _on_GUI_play_again():
	score = 0
	total_lines_cleared = 0
	$GUI.set_score(score)
	$GUI.set_cleared_lines(total_lines_cleared)
	$GUI.set_next_block(null)
	$GUI.set_hold_block(null)
	play_bgm()
	$Grid.restart_game()

func _on_Grid_game_over():
	$BackgroundMusicPlayer.stop()
	$GUI.game_over()

func _on_Grid_pause(paused):
	if paused:
		paused_music_position = $BackgroundMusicPlayer.get_playback_position()
		$BackgroundMusicPlayer.stop()
	else:
		$BackgroundMusicPlayer.play(paused_music_position)
	$GUI.toggle_pause(paused)
