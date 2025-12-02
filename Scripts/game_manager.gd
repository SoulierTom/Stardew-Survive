extends Node

var score: int = 0

func add_score(amount: int = 1):
	score += amount
	print("Score : ", score)
