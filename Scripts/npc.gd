extends CharacterBody2D

var player_is_near = false
@onready var dialogue_system: Dialogue_system = $"../../UI/Dialogue"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var sprites: SpriteFrames

func _ready() -> void:
	if sprites:
		animated_sprite.sprite_frames = sprites
		animated_sprite.play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_is_near = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_is_near = false
		
func _input(event):
	if player_is_near:
		if event.is_action_pressed("ui_accept"):
			dialogue_system.start("res://Dialogues/test_chat.json")
