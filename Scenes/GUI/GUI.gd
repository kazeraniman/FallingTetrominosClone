extends CanvasLayer

func set_score(score):
	$StatsPanel/VBoxContainer/ScoreLabel.text = str(score)

func set_cleared_lines(cleared_lines):
	$StatsPanel/VBoxContainer/LinesClearedLabel.text = str(cleared_lines)
