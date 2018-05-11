extends Node2D

var MainGameScene = preload("res://Scenes/Main/Main.tscn")

func _on_PlayButton_pressed():
	get_tree().change_scene_to(MainGameScene)
