extends VBoxContainer

class_name InventorySlot

signal equip_item
signal drop_item
signal slot_clicked
signal eat_item

var is_empty = true
var is_selected = false

@export var single_button_press = false
@export var starting_texture: Texture
@export var start_label: String

@onready var texture_rect: TextureRect = $NinePatchRect/MenuButton/CenterContainer/TextureRect
@onready var name_label: Label = $NameLabel
@onready var stacks_label: Label = $NinePatchRect/StacksLabel
@onready var on_click_button: Button = $NinePatchRect/OnClickButton
@onready var price_label: Label = $PriceLabel
@onready var menu_button: MenuButton = $NinePatchRect/MenuButton

var slot_to_equip = "NotEquipable"

func _ready() -> void:
	
	if starting_texture != null:
		texture_rect.texture = starting_texture
	
	if start_label != null:
		name_label.text = start_label
	
	menu_button.disabled = true
	on_click_button.disabled = !single_button_press
	
	on_click_button.visible = single_button_press
	
	var popup_menu = menu_button.get_popup()
	popup_menu.id_pressed.connect(on_popup_menu_item_pressed)

func on_popup_menu_item_pressed(id: int):
	var popup_menu = menu_button.get_popup()
	if id < 0 or id >= popup_menu.get_item_count():
		print("Invalid menu item index:", id)
		return
	
	var pressed_menu_item = popup_menu.get_item_text(id)
	
	if pressed_menu_item.contains("Выбросить"):
		print("Выброс")
		drop_item.emit()
		menu_button.disabled = true	
	elif pressed_menu_item.contains("Надеть") and slot_to_equip == "Equipable":
		equip_item.emit()
	elif pressed_menu_item.contains("Съесть"):
		eat_item.emit()

		

func add_item(item: InventoryItem): 
	var popup_menu: PopupMenu = menu_button.get_popup()
	
	popup_menu.clear()
	match item.slot_equip:
		"Equipable":
			slot_to_equip = item.slot_equip
			popup_menu.add_item("Надеть")  
			# popup_menu.add_item("Выбросить", 1)
		_:
			pass
	match item.slot_type:
		"Weapon":
			pass
		"Food":
			popup_menu.add_item("Съесть") 
		"Other":
			pass

	popup_menu.add_item("Выбросить")

	is_empty = false
	menu_button.disabled = false
	texture_rect.texture = item.texture
	name_label.text = item.name
	
	if item.stacks > 1:
		stacks_label.text = str(item.stacks)

		
		
#func _on_on_click_button_pressed() -> void:
	#slot_clicked.emit()
#
#
#func toggle_button_selected_variation(is_selected: bool):
	#on_click_button.theme_type_variation = "selected" if is_selected else ""
#
#func show_price_tag(price: int):
	#price_label.text = str(price) + " gold"
	#price_label.show()
