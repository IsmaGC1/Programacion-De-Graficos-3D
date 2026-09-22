extends Node
class_name NPCBrain

# Señal para notificar a la interfaz cuando la respuesta de la IA esté lista
signal response_received(reply_text: String)

@export var use_local_ai: bool = true
@export var api_key: String = "TU_API_KEY_AQUI" # Solo si usas OpenAI

var api_url_openai: String = "https://api.openai.com/v1/chat/completions"
var api_url_local: String = "http://localhost:1234/v1/chat/completions"

# System Prompt: Define la personalidad del NPC
@export_multiline var system_prompt: String = "Eres un sabio anciano en un juego de fantasía. Responde siempre de forma mística y en un máximo de 30 palabras."

var http_request: HTTPRequest

func _ready() -> void:
	# Búsqueda segura del nodo hijo HTTPRequest
	http_request = $HTTPRequest if has_node("HTTPRequest") else get_node_or_null("HTTPRequest")
	
	if http_request:
		http_request.request_completed.connect(_on_request_completed)
	else:
		push_error("Error: No se encontró el nodo hijo 'HTTPRequest' dentro de NPCBrain.")

func ask_npc(player_message: String) -> void:
	if not http_request:
		push_error("HTTP Request no está inicializado.")
		return
		
	var url = api_url_local if use_local_ai else api_url_openai
	
	var headers = [
		"Content-Type: application/json"
	]
	
	if not use_local_ai:
		headers.append("Authorization: Bearer " + api_key)
	
	var payload = {
		"model": "llama-3.2-1b-instruct" if use_local_ai else "gpt-3.5-turbo",
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": player_message}
		],
		"temperature": 0.7,
		"max_tokens": 80
	}
	
	var json_body = JSON.stringify(payload)
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		push_error("Error al realizar la petición HTTP: %d" % error)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.get_data()
			if response_data.has("choices") and response_data["choices"].size() > 0:
				var reply = response_data["choices"][0]["message"]["content"]
				response_received.emit(reply.strip_edges())
			else:
				response_received.emit("Error: Formato de respuesta inesperado.")
		else:
			response_received.emit("Error: No se pudo interpretar la respuesta JSON.")
	else:
		response_received.emit("Error en la conexión con la IA (Código HTTP: %d)." % response_code)
