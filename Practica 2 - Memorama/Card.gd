extends Button
class_name MemoryCard

signal card_selected(card: MemoryCard)

var card_id: int = 0
var is_revealed: bool = false
var is_matched: bool = false

@onready var front_image: TextureRect = $TextureRect
@onready var back_image: TextureRect = $BackImage

func setup(id: int, front_texture: Texture2D) -> void:
	card_id = id
	front_image.texture = front_texture
	hide_card()

func reveal_card() -> void:
	if is_matched or is_revealed:
		return
	is_revealed = true
	front_image.visible = true
	back_image.visible = false

func hide_card() -> void:
	if is_matched:
		return
	is_revealed = false
	front_image.visible = false
	back_image.visible = true

func set_matched() -> void:
	is_matched = true
	disabled = true
	modulate = Color(0.6, 0.6, 0.6, 0.5)

func _on_pressed() -> void:
	if not is_revealed and not is_matched:
		emit_signal("card_selected", self)
