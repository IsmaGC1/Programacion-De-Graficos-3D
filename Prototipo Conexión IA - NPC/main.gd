extends Node2D

@onready var npc_brain: NPCBrain = $NPC/NPCBrain
@onready var dialogue_ui: Control = $DialogueUI

func _ready() -> void:
	# Abrimos el diálogo automáticamente al iniciar para probar rápido
	dialogue_ui.open_dialogue(npc_brain)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		dialogue_ui.open_dialogue(npc_brain)
