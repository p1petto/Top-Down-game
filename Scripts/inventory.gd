extends Node

class_name Inventory

#signal spell_activated(spell_index: int)
#
@onready var inventory_ui: InventoryUI = $"../InventroryUI"
@onready var on_screen_ui: OnScreenUI = $"../OnScreenUI"
@onready var player: Player = $"../"
@onready var animated_sprite_2d: AnimationController = $"../Sprite2D"
@onready var world = $"../../"

const PICKUP_ITEM_SCENE = preload("res://Scenes/pick_up_item.tscn")

# items currently in inventory
@export var items: Array[InventoryItem] = []
#
var taken_inventory_slots_count = 0
#var selected_spell_index = -1 
#
func _ready() -> void:
	inventory_ui.equip_item.connect(on_item_equipped)
	inventory_ui.drop_item_on_the_ground.connect(on_item_dropped)
	#inventory_ui.spell_slot_clicked.connect(on_spell_slot_clicked)
	if len(items) > 0:
		for item in items:
			inventory_ui.add_item(item)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.toggle()
	
		


func add_item(item: InventoryItem, stacks: int):
	#print_debug(item.name)
	if stacks && item.max_stacks > 1:
		add_stackable_item_to_inventory(item, stacks)
	else:
		#items.append(item)
		var idx = items.find(null)
		if idx != -1:
			items[idx] = item
		else: 
			items.append(item)
		inventory_ui.add_item(item)
		taken_inventory_slots_count += 1
	GameData.player_inventory = items.duplicate()
	 #
func add_stackable_item_to_inventory(item: InventoryItem, stacks: int):
	
	var empty_slot_index = items.find(null)
	var existing_item_index = -1
	
	for i in items.size():
		if items[i] != null and items[i].name == item.name:
			existing_item_index = i
			break
	
	if existing_item_index != -1:
		var inventory_item = items[existing_item_index]
		if inventory_item.stacks + stacks <= item.max_stacks:
			inventory_item.stacks += stacks 
			items[existing_item_index] = inventory_item
			inventory_ui.update_stack_at_slot_index(inventory_item.stacks, existing_item_index)
		else:
			var stacks_diff = inventory_item.stacks + stacks - item.max_stacks
			var additional_inventory_item = inventory_item.duplicate(true)
			inventory_item.stacks = item.max_stacks
			inventory_ui.update_stack_at_slot_index(inventory_item.max_stacks, existing_item_index)
			
			additional_inventory_item.stacks = stacks_diff
			if empty_slot_index != -1:
				items[empty_slot_index] = additional_inventory_item
				inventory_ui.add_item(additional_inventory_item)
			else:
				items.append(additional_inventory_item)
				inventory_ui.add_item(additional_inventory_item)
			taken_inventory_slots_count += 1
	else:
		item.stacks = stacks
		if empty_slot_index != -1:
			items[empty_slot_index] = item
			inventory_ui.add_item(item)
		else:
			items.append(item)
			inventory_ui.add_item(item)
		taken_inventory_slots_count += 1

func on_item_equipped(idx: int, slot_to_equip: String):
	var item_to_equip = items[idx]
	print_debug(item_to_equip.name)
	on_screen_ui.equip_item(item_to_equip, slot_to_equip)
	#player.hand_weapon = item
	player.set_active_weapon(items[idx], slot_to_equip)
	GameData.player_stats.hand_weapon = item_to_equip


func on_item_dropped(idx: int):
	clear_inventory_slot(idx)
	eject_item_into_the_ground(idx)
	

func clear_inventory_slot(idx: int):
	taken_inventory_slots_count -= 1
	inventory_ui.clear_slot_at_index(idx)
	
func eject_item_into_the_ground(idx: int):
	
	var inventory_item_to_eject = items[idx]
	var item_to_eject_as_pickup = PICKUP_ITEM_SCENE.instantiate() as PickUpItem
	
	item_to_eject_as_pickup.inventory_item = inventory_item_to_eject
	item_to_eject_as_pickup.stacks = inventory_item_to_eject.stacks
	
	get_tree().root.add_child(item_to_eject_as_pickup)
	#world.add_child(item_to_eject_as_pickup)
	item_to_eject_as_pickup.disable_collision()
	item_to_eject_as_pickup.global_position = get_parent().global_position
	
	var eject_direction = animated_sprite_2d.item_eject_direction
	
	if eject_direction.x == 0:
		eject_direction.x = randf_range(-1, 1)
	else:
		eject_direction.y = randf_range(-1, 1)
	
	var eject_position = get_parent().global_position + Vector2(20, 20) * eject_direction
	
	var ejection_tween = get_tree().create_tween()
	ejection_tween.set_trans(Tween.TRANS_BOUNCE)
	ejection_tween.tween_property(item_to_eject_as_pickup, "global_position", eject_position, .2)
	ejection_tween.finished.connect(func(): item_to_eject_as_pickup.enable_collision())
	
	if player.hand_weapon == inventory_item_to_eject:
		player.hand_weapon = null
		on_screen_ui.hand_slot.set_equipment_texture(null)
		
	items[idx] = null
	
