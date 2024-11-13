extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var sprites: SpriteFrames
@export var dialogue_resource: DialogueResource
var can_interact = false
var is_dialogue_active = false

func _input(event):
	if event.is_action_pressed("interact") and can_interact and dialogue_resource and not is_dialogue_active:
		start_dialogue()

func start_dialogue():
	is_dialogue_active = true
	DialogueManager.show_dialogue_balloon(dialogue_resource, "this_is_a_node_title")

func _on_dialogue_finished():
	is_dialogue_active = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		can_interact = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		can_interact = false
