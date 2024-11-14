extends Node

class_name Market

@onready var market_ui: MarketUI = $"../MarketUI"

var items: Array[InventoryItem] = []
#
var taken_inventory_slots_count = 0
#
func _ready() -> void:
	market_ui.move_item_to_player.connect(on_item_buyed)


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
		market_ui.add_item(item)
		taken_inventory_slots_count += 1
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
			market_ui.update_stack_at_slot_index(inventory_item.stacks, existing_item_index)
		else:
			var stacks_diff = inventory_item.stacks + stacks - item.max_stacks
			var additional_inventory_item = inventory_item.duplicate(true)
			inventory_item.stacks = item.max_stacks
			market_ui.update_stack_at_slot_index(inventory_item.max_stacks, existing_item_index)
			
			additional_inventory_item.stacks = stacks_diff
			if empty_slot_index != -1:
				items[empty_slot_index] = additional_inventory_item
				market_ui.add_item(additional_inventory_item)
			else:
				items.append(additional_inventory_item)
				market_ui.add_item(additional_inventory_item)
			taken_inventory_slots_count += 1
	else:
		item.stacks = stacks
		if empty_slot_index != -1:
			items[empty_slot_index] = item
			market_ui.add_item(item)
		else:
			items.append(item)
			market_ui.add_item(item)
		taken_inventory_slots_count += 1

func on_item_equipped(idx: int, slot_to_equip: String):
	var item_to_equip = items[idx]
	print_debug(item_to_equip.name)


func on_item_dropped(idx: int):
	clear_inventory_slot(idx)
	
func on_item_buyed(idx: int):
	clear_inventory_slot(idx)
	

func clear_inventory_slot(idx: int):
	taken_inventory_slots_count -= 1
	market_ui.clear_slot_at_index(idx)
	
