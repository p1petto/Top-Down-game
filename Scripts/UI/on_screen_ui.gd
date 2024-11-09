extends CanvasLayer

class_name OnScreenUI

@onready var hand_slot: OnScreenEquipmentSlot = %HandSlot
@onready var player: Player = $"../"

@onready var slots_dictionary = {
	"Weapon": hand_slot,
	"Tool": hand_slot
}

func equip_item(item: InventoryItem, slot_to_equip: String):
	player.equipped = true
	player.power = item.damage
	player.tool_type = item.tool_type
	player.power = item.damage
	slots_dictionary[slot_to_equip].set_equipment_texture(item.texture)
