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

# inventory_items currently in inventory
@export var inventory_items: Array[InventoryItem] = []
#
var taken_inventory_slots_count = 0
var global_inventory = GameData.player_stats.player_inventory
#var selected_spell_index = -1 
#
func _ready() -> void:
	inventory_ui.equip_item.connect(on_item_equipped)
	inventory_ui.drop_item_on_the_ground.connect(on_item_dropped)
	#inventory_ui.spell_slot_clicked.connect(on_spell_slot_clicked)
	if len(global_inventory) > 0:
		inventory_items = global_inventory.duplicate(true)
		for item in inventory_items:
			if item != null:
				inventory_ui.add_item(item)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.toggle()
	
		
func add_item(item: InventoryItem, stacks: int):
	#print_debug(item.name)
	if stacks && item.max_stacks > 1:
		add_stackable_item_to_inventory(item, stacks)
	else:
		#inventory_items.append(item)
		var idx = inventory_items.find(null)
		if idx != -1:
			inventory_items[idx] = item
		else:
			inventory_items.append(item)
		inventory_ui.add_item(item)
		taken_inventory_slots_count += 1
	GameData.player_stats.player_inventory = inventory_items.duplicate(true)
	 #
func add_stackable_item_to_inventory(item: InventoryItem, stacks: int):
	# item.stacks = stacks
	print_debug("item.stacks: %d, stacks: %d, max_stacks: %d" % [item.stacks, stacks, item.max_stacks])
	# var empty_slot_index = inventory_items.find(null)
	var existing_items: Array[int] = []
	for i in inventory_items.size():
		if inventory_items[i] != null and inventory_items[i].name == item.name:
			existing_items.append(i)
	
	print_debug(existing_items)

	var remains_stacks := stacks
	for i in existing_items:
		remains_stacks = addStackToStackable(inventory_items[i],stacks)
		inventory_ui.update_stack_at_slot_index(inventory_items[i].stacks, i)
		if remains_stacks == 0:
			break
	print_debug("Осталось",remains_stacks / item.max_stacks + 1)
	for i in range(remains_stacks / item.max_stacks + 1):
		var new_item := item.duplicate(true)
		remains_stacks = addStackToStackable(new_item, remains_stacks)
		print_debug(remains_stacks)
		var empty_slot_index = inventory_items.find(null)
		print_debug(inventory_items)
		if empty_slot_index == -1:
			printerr("Место кончилось :(")
			return
		inventory_items[empty_slot_index] = new_item
		inventory_ui.add_item(new_item)


	

## addStackToStackable добавляет stacks к item и возвращает количество которое не вместилось
func addStackToStackable(item: InventoryItem, stacks: int) -> int:
	print_debug("item.stacks: %d, stacks: %d, max_stacks: %d" % [item.stacks, stacks, item.max_stacks])
	var integr: int = (item.stacks + stacks) / item.max_stacks
	var remainder: int = (item.stacks + stacks) % item.max_stacks
	print_debug("integr: %d, remainder: %d" % [integr, remainder])
	if integr > 0: 
		item.stacks = item.max_stacks
		return integr * remainder
	item.stacks = remainder
	return integr * remainder
	
func on_item_equipped(idx: int):
	assert(idx <= inventory_items.size(), "item id`s over array")
	var item_to_equip = inventory_items[idx]
	print_debug(item_to_equip.name)
	on_screen_ui.equip_item(item_to_equip)
	#player.hand_weapon = item
	player.set_active_weapon(inventory_items[idx])
	GameData.player_stats.hand_weapon = item_to_equip


func on_item_dropped(idx: int):
	clear_inventory_slot(idx)
	eject_item_into_the_ground(idx)
	

func clear_inventory_slot(idx: int):
	taken_inventory_slots_count -= 1
	inventory_ui.clear_slot_at_index(idx)
	
func eject_item_into_the_ground(idx: int):
	
	var inventory_item_to_eject = inventory_items[idx]
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
		
	inventory_items[idx] = null
