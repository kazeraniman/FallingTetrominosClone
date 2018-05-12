extends Node2D

var MainGameScene = preload("res://Scenes/Main/Main.tscn")

func _physics_process(delta):
	if Input.is_action_just_released("play_button"):
		switch_to_main_scene()

func _on_PlayButton_pressed():
	switch_to_main_scene()

func switch_to_main_scene():
	"""
	Starts the actual game.
	"""
	get_tree().change_scene_to(MainGameScene)
