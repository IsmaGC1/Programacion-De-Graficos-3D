extends Control

@onready var dialogue_text: RichTextLabel = $CanvasLayer/Panel/VBoxContainer/DialogueText
@onready var player_input: LineEdit = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/PlayerInput
@onready var send_button: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/SendButton

var current_npc_brain: NPCBrain = null

func _ready() -> void:
	hide() # Ocultar la interfaz al arrancar el juego
	send_button.pressed.connect(_on_send_pressed)
	player_input.text_submitted.connect(_on_text_submitted)

func open_dialogue(npc_brain: NPCBrain) -> void:
	current_npc_brain = npc_brain
	show()
	dialogue_text.text = "NPC: Saludos, viajero. ¿Qué deseas consultar?"
	
	# Desconectamos señales anteriores para evitar múltiples llamadas
	if current_npc_brain.response_received.is_connected(_on_npc_response):
		current_npc_brain.response_received.disconnect(_on_npc_response)
		
	current_npc_brain.response_received.connect(_on_npc_response)

func _on_send_pressed() -> void:
	_send_message()

func _on_text_submitted(_new_text: String) -> void:
	_send_message()

func _send_message() -> void:
	var text = player_input.text.strip_edges()
	if text == "" or current_npc_brain == null:
		return
		
	dialogue_text.text = "Tú: " + text + "\n\n(Pensando respuesta...)"
	player_input.text = ""
	
	current_npc_brain.ask_npc(text)

func _on_npc_response(reply: String) -> void:
	dialogue_text.text = "NPC: " + reply
