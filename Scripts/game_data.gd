extends Node

const player_stats_init: PlayerStats = preload("res://Resources/Player/player_stats.tres")

var player_stats: PlayerStats:
	set(value):
		player_stats = value
	get:
		if not player_stats:
			player_stats = player_stats_init
		return player_stats
