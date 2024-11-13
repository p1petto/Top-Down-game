extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var market: Market = $Market
@onready var market_ui: MarketUI = $MarketUI

@export var sprites: SpriteFrames
@export var dialogue_resource: DialogueResource
@export var items: Array[InventoryItem] = []

var can_interact = false
var is_dialogue_active = false

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	if len(items) > 0:
		market.items = items.duplicate()
		for item in items:
			market_ui.add_item(item)

func _input(event):
	if event.is_action_pressed("interact") and can_interact and dialogue_resource and not is_dialogue_active:
		start_dialogue()

func start_dialogue():
	is_dialogue_active = true
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	

func on_dialogue_ended(dialogue_resource):
	is_dialogue_active = false
	print ("finish")
	if len(market.items) > 0:
		market_ui.toggle()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		can_interact = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		can_interact = false
