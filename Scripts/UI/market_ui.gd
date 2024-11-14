extends CanvasLayer

class_name MarketUI

signal move_item_to_player(idx: int)
#
@onready var grid_container: GridContainer = %GridContainer

const MARKET_SLOT_SCENE = preload("res://Scenes/UI/market_slot.tscn")

@export var size = 8
@export var columns = 4
#
func _ready():
	grid_container.columns = columns
	
	for i in size:
		var market_slot = MARKET_SLOT_SCENE.instantiate()
		grid_container.add_child(market_slot)
		
		market_slot.buy_item.connect(func (): move_item_to_player.emit(i))

	#for i in spell_slots.size():
		#spell_slots[i].slot_clicked.connect(on_spell_slot_clicked.bind(i))

func toggle():
	#visible = !visible
	if visible == true:
		visible = false
		get_tree().paused = false
		
	else:
		visible = true
		get_tree().paused = true


func add_item(item: InventoryItem):
	var slots = grid_container.get_children().filter(func (slot): return slot.is_empty)
	var first_empty_slot = slots.front() as MarketSlot
	first_empty_slot.add_item(item)
	

func update_stack_at_slot_index(stacks_value: int, inventory_slot_index: int):
	if inventory_slot_index == -1:
		return
	var inventory_slot: MarketSlot = grid_container.get_child(inventory_slot_index)
	inventory_slot.stacks_label.text = str(stacks_value)

func clear_slot_at_index(idx: int):
	var empty_market_slot: MarketSlot = MARKET_SLOT_SCENE.instantiate()
	toggle()
	
	empty_market_slot.buy_item.connect(func(): move_item_to_player.emit(idx))
	
	var child_to_remove = grid_container.get_child(idx)
	grid_container.remove_child(child_to_remove)
	grid_container.add_child(empty_market_slot)
	grid_container.move_child(empty_market_slot, idx)
	
