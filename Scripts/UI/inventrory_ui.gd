extends CanvasLayer

class_name InventoryUI

signal drop_item_on_the_ground(idx: int)
signal equip_item(idx: int, slot_to_equip)
signal eat_item(idx)
signal spell_slot_clicked(idx: int)
#
@onready var grid_container: GridContainer = %GridContainer

#@onready var spell_slots: Array[InventorySlot] = [
	#%FireSpellSlot,
	#%IceSpellSlot,
	#%PlantSpellSlot
#]
#@onready var spells_ui: VBoxContainer = %SpellsUI
#
const INVENTORY_SLOT_SCENE = preload("res://Scenes/UI/inventory_slot.tscn")

@export var size = 8
@export var columns = 4
#
func _ready():
	print("Hello from ready")
	for n in grid_container.get_children():
		grid_container.remove_child(n)
		n.queue_free()
	grid_container.columns = columns
	
	for i in size:
		var inventory_slot = INVENTORY_SLOT_SCENE.instantiate()
		grid_container.add_child(inventory_slot)
		
		inventory_slot.equip_item.connect(func(): equip_item.emit(i))
		inventory_slot.drop_item.connect(func (): drop_item_on_the_ground.emit(i))
		inventory_slot.eat_item.connect(func (): eat_item.emit(i))

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

func eating(i):
	clear_slot_at_index(i)

func add_item(item: InventoryItem):
	var slots = grid_container.get_children().filter(func (slot): return slot.is_empty)
	var first_empty_slot = slots.front() as InventorySlot
	first_empty_slot.add_item(item)
	print("add_item")
	

func update_stack_at_slot_index(stacks_value: int, inventory_slot_index: int):
	if inventory_slot_index == -1:
		return
	print_debug("UPDATE STACK: ", inventory_slot_index)
	var inventory_slot: InventorySlot = grid_container.get_child(inventory_slot_index)
	inventory_slot.stacks_label.text = str(stacks_value)

func clear_slot_at_index(idx: int):
	var empty_inventory_slot: InventorySlot = INVENTORY_SLOT_SCENE.instantiate()
	toggle()
	
	empty_inventory_slot.drop_item.connect(func(): drop_item_on_the_ground.emit(idx))
	empty_inventory_slot.equip_item.connect(func(): equip_item.emit(idx))
	empty_inventory_slot.eat_item.connect(func (): eat_item.emit(idx))
	
	var child_to_remove = grid_container.get_child(idx)
	grid_container.remove_child(child_to_remove)
	grid_container.add_child(empty_inventory_slot)
	grid_container.move_child(empty_inventory_slot, idx)
	
#func on_spell_slot_clicked(i: int):
	#spell_slot_clicked.emit(i)
#
#func set_selected_spell_slot(idx: int):
	#for i in spell_slots.size():
		#spell_slots[i].toggle_button_selected_variation(idx == i)
#
#func toggle_spells_ui(is_visible: bool):
	#spells_ui.visible = is_visible
