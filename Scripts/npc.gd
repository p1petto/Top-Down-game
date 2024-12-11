extends CharacterBody2D

@onready var animated_sprite_npc: AnimatedSprite2D = $AnimatedSprite2D

@export var sprites: SpriteFrames
@export var flip: bool = false
@export var dialogue_resource: DialogueResource
@export var item: InventoryItem

var can_interact = false
var is_dialogue_active = false

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	#item_sale.connect(on_dialogue_ended)
	if sprites:
		animated_sprite_npc.sprite_frames = sprites
	if flip:
		animated_sprite_npc.flip_h = true
	animated_sprite_npc.play("default")
	

func _input(event):
	if event.is_action_pressed("interact") and can_interact and dialogue_resource and not is_dialogue_active:
		start_dialogue()

func start_dialogue():
	is_dialogue_active = true
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	

func on_dialogue_ended(dialogue_resource):
	#print ("end")
	is_dialogue_active = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		can_interact = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		can_interact = false
