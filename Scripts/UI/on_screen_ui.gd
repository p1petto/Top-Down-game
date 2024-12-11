extends CanvasLayer

class_name OnScreenUI

@onready var hand_slot: OnScreenEquipmentSlot = %HandSlot

@onready var slots_dictionary = {
	"Weapon": hand_slot
}

func equip_item(item: InventoryItem):
	if slots_dictionary.get(item.slot_type) != null:
		slots_dictionary[item.slot_type].set_equipment_texture(item.texture)
	else:
		print_debug("Разработчик!: такой ячейки еще нет!")
