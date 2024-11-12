
extends Node

var player_stats: PlayerStats:
	set(value):
		player_stats = value
		
	get:
		if not player_stats:
			player_stats = PlayerStats.new()
		return player_stats
