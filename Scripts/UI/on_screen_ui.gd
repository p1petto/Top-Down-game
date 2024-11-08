extends CanvasLayer

class_name OnScreenUI

@onready var hand_slot: OnScreenEquipmentSlot = %HandSlot


@onready var slots_dictionary = {
	"Weapon": hand_slot,
	"Tool": hand_slot
}

func equip_item(item: InventoryItem, slot_to_equip: String):
	slots_dictionary[slot_to_equip].set_equipment_texture(item.texture)
