extends Control

@export var card_scene: PackedScene = preload("res://Card.tscn")
@export var card_textures: Array[Texture2D] = []

@onready var grid: GridContainer = $GridContainer
@onready var status_label: Label = $MarginContainer/HBoxContainer/StatusLabel
@onready var timer_label: Label = $MarginContainer/HBoxContainer/TimerLabel

var total_pairs: int = 16
var flipped_cards: Array[MemoryCard] = []
var matched_pairs: int = 0
var can_flip: bool = true
var attempts: int = 0

var elapsed_time: float = 0.0
var is_game_active: bool = false

func _ready() -> void:
	setup_game()

func _process(delta: float) -> void:
	if is_game_active:
		elapsed_time += delta
		timer_label.text = "Tiempo: %d s" % int(elapsed_time)

func setup_game() -> void:
	matched_pairs = 0
	attempts = 0
	elapsed_time = 0.0
	is_game_active = true
	flipped_cards.clear()
	can_flip = true
	
	status_label.text = "Intentos: 0"
	timer_label.text = "Tiempo: 0 s"

	# Limpiar cartas previas
	for child in grid.get_children():
		child.queue_free()

	# Generar los 16 pares (32 cartas en total)
	var ids: Array[int] = []
	for i in range(total_pairs):
		ids.append(i)
		ids.append(i)

	ids.shuffle()

	# Instanciar cada carta en la cuadrícula
	for id in ids:
		var new_card = card_scene.instantiate() as MemoryCard
		grid.add_child(new_card)
		
		var texture_to_use: Texture2D
		if id < card_textures.size() and card_textures[id] != null:
			texture_to_use = card_textures[id]
		else:
			texture_to_use = preload("res://icon.svg")
			
		new_card.setup(id, texture_to_use)
		new_card.card_selected.connect(_on_card_selected)

func _on_card_selected(card: MemoryCard) -> void:
	if not can_flip or flipped_cards.size() >= 2:
		return

	card.reveal_card()
	flipped_cards.append(card)

	if flipped_cards.size() == 2:
		attempts += 1
		status_label.text = "Intentos: " + str(attempts)
		check_match()

func check_match() -> void:
	can_flip = false
	var first = flipped_cards[0]
	var second = flipped_cards[1]

	if first.card_id == second.card_id:
		first.set_matched()
		second.set_matched()
		matched_pairs += 1
		flipped_cards.clear()
		can_flip = true

		if matched_pairs == total_pairs:
			is_game_active = false
			status_label.text = "¡Victoria en %d intentos y %d s!" % [attempts, int(elapsed_time)]
	else:
		await get_tree().create_timer(0.8).timeout
		first.hide_card()
		second.hide_card()
		flipped_cards.clear()
		can_flip = true

func _on_restart_button_pressed() -> void:
	setup_game()
