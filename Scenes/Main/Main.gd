extends Node2D

var bgm = [preload("res://Audio/Music/bgm1.wav"), preload("res://Audio/Music/bgm2.wav")]

const BASE_LINE_SCORE = 10
const EXTRA_LINE_MULTIPLIER = 2
const MAX_SCORE_LINES = 99999999999
const LINES_TO_LEVEL_UP = 10
const MAX_LEVEL = 25

var score = 0
var total_lines_cleared = 0
var level = 0
var lines_since_level = 0
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

func should_level_up():
	"""
	Determine whether enough lines have been cleared to warrant an increase in difficulty.
	"""
	# Don't want to go above the max level
	if level == MAX_LEVEL:
		return
	# Level up if it's time
	if lines_since_level >= LINES_TO_LEVEL_UP:
		lines_since_level %= LINES_TO_LEVEL_UP
		level += 1
		$GUI.set_level(level)
		$Grid.level_up()

func _on_Grid_lines_cleared(lines_cleared):
	total_lines_cleared += lines_cleared
	lines_since_level += lines_cleared
	clamp(total_lines_cleared, 0, MAX_SCORE_LINES)
	score += BASE_LINE_SCORE * int(pow(EXTRA_LINE_MULTIPLIER, lines_cleared - 1))
	clamp(score, 0, MAX_SCORE_LINES)
	$GUI.set_score(score)
	$GUI.set_cleared_lines(total_lines_cleared)
	should_level_up()

func _on_Grid_next_tetromino(next_tetromino):
	$GUI.set_next_block(next_tetromino)

func _on_Grid_hold_tetromino(tetromino):
	$GUI.set_hold_block(tetromino)

func _on_GUI_play_again():
	score = 0
	total_lines_cleared = 0
	level = 1
	lines_since_level = 0
	$GUI.set_score(score)
	$GUI.set_cleared_lines(total_lines_cleared)
	$GUI.set_level(level)
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
