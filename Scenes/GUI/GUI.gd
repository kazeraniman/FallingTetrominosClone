extends CanvasLayer

signal play_again

var Utility = preload("res://Scripts/Utility.gd")

var pause_sound = preload("res://Audio/Sounds/pause.wav")
var unpause_sound = preload("res://Audio/Sounds/unpause.wav")

var animation_position

const LINE_CLEAR_COUNT = {
	1: "SINGLE!",
	2: "DOUBLE!",
	3: "TRIPLE!",
	4: "QUADRUPLE!"
}

func _physics_process(delta):
	# Only handle the keypress if the button is active
	if Input.is_action_just_released("play_button") and !$GameOverPanel/VBoxContainer/CenterContainer/PlayAgainButton.disabled:
		play_again()

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
	:param cleared_lines: The lines cleared to set.
	:type cleared_lines: Int.
	"""
	$StatsPanel/VBoxContainer/LinesClearedLabel.text = str(cleared_lines)

func set_level(level):
	"""
	Sets the level on the GUI to the provided value.
	:param level: The level to set.
	:type level: Int.
	"""
	$StatsPanel/VBoxContainer/LevelLabel.text = str(level)

func set_next_block(next_block):
	"""
	Sets the texture of next block on the GUI to the block image matching the input.
	:param next_block: The block type to be displayed.
	:type next_block: GridValues.
	"""
	if next_block == null:
		$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = null
	else:
		$NextTetrominoPanel/VBoxContainer/NextTetrominoImage.texture = Utility.TETROMINO_TEXTURES[next_block]

func set_hold_block(held_block):
	"""
	Sets the texture of held block on the GUI to the block image matching the input.
	:param held_block: The block type to be displayed.
	:type held_block: GridValues.
	"""
	if held_block == null:
		$HeldTetrominoPanel/VBoxContainer/HeldTetrominoImage.texture = null
	else:
		$HeldTetrominoPanel/VBoxContainer/HeldTetrominoImage.texture = Utility.TETROMINO_TEXTURES[held_block]

func game_over():
	"""
	Plays the game over sequence.
	"""
	$AnimationPlayer.stop()
	$AnimationPlayer.play("show_game_over")

func toggle_pause(paused):
	"""
	Perform the UI changes for pausing / unpausing.
	:param paused: Whether the game is paused or not.
	:type paused: Boolean.
	"""
	if paused:
		$PausePanel.show()
		animation_position = $AnimationPlayer.current_animation_position
		$AnimationPlayer.stop()
		$SoundEffectsPlayer.stream = pause_sound
	else:
		$PausePanel.hide()
		$AnimationPlayer.play("show_line_clear_message")
		$AnimationPlayer.seek(animation_position)
		$SoundEffectsPlayer.stream = unpause_sound

	$SoundEffectsPlayer.play()

func play_again():
	"""
	Prepare to play again.
	"""
	$GameOverPanel/VBoxContainer/CenterContainer/PlayAgainButton.disabled = true
	$GameOverPanel.hide()
	$AnimationPlayer.stop()
	$LineClearMessagePanel/CenterContainer/LineClearLabel.hide()
	emit_signal("play_again")

func set_line_clear_message(lines_cleared, clear_type, multiplier):
	"""
	Sets the message to be displayed to the player regarding their last clear.
	:param lines_cleared: The number of lines cleared.
	:param clear_type: Whether or not the line clear was a T-Spin.
	:param multiplier: The current multiplier which comes down to how many similar clears have occurred in a row.
	:type lines_cleared: Int.
	:type clear_type: ClearTypes.
	:type multiplier: Int. 
	"""
	var line_clear_message = ""
	# Cap the multiplier so it doesn't stretch out unbounded
	if multiplier > 9:
		line_clear_message += "x9+ "
	# We don't care about a multiplier of one as that's not back to back so just look at the other cases
	elif multiplier > 1:
		line_clear_message += "x{0} ".format([multiplier])
	# Check if we need the T-Spin message
	if clear_type == Utility.TSPIN:
		line_clear_message += "T-SPIN "
	# Finally, the actual line clear count
	line_clear_message += LINE_CLEAR_COUNT[lines_cleared]
	# Set the label
	$LineClearMessagePanel/CenterContainer/LineClearLabel.text = line_clear_message

func display_line_clear_message(lines_cleared, clear_type, multiplier):
	"""
	Displays the line clear message to the player.
	:param lines_cleared: The number of lines cleared.
	:param clear_type: Whether or not the line clear was a T-Spin.
	:param multiplier: The current multiplier which comes down to how many similar clears have occurred in a row.
	:type lines_cleared: Int.
	:type clear_type: ClearTypes.
	:type multiplier: Int. 
	"""
	$LineClearMessagePanel/CenterContainer/LineClearLabel.hide()
	set_line_clear_message(lines_cleared, clear_type, multiplier)
	$AnimationPlayer.play("show_line_clear_message")

func _on_PlayAgainButton_pressed():
	play_again()
