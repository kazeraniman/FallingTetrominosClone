extends CanvasLayer

signal play_again

var pause_sound = preload("res://Audio/Sounds/pause.wav")
var unpause_sound = preload("res://Audio/Sounds/unpause.wav")

var Utility = preload("res://Scripts/Utility.gd")

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
	$AnimationPlayer.play("show_game_over")

func toggle_pause(paused):
	"""
	Perform the UI changes for pausing / unpausing.
	:param paused: Whether the game is paused or not.
	:type paused: Boolean.
	"""
	if paused:
		$PausePanel.show()
		$SoundEffectsPlayer.stream = pause_sound
	else:
		$PausePanel.hide()
		$SoundEffectsPlayer.stream = unpause_sound

	$SoundEffectsPlayer.play()

func play_again():
	"""
	Prepare to play again.
	"""
	$GameOverPanel/VBoxContainer/CenterContainer/PlayAgainButton.disabled = true
	$GameOverPanel.hide()
	emit_signal("play_again")

func _on_PlayAgainButton_pressed():
	play_again()
