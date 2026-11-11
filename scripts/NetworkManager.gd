extends Node

const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 10

var peer: ENetMultiplayerPeer
var server_ip: String = "127.0.0.1"
var server_port: int = DEFAULT_PORT

var player_name: String = "Player"
var room_code: String = "491881"
var current_room: String = ""

# Connected players: id -> {name, kills, deaths, team, room}
var players: Dictionary = {}

signal player_list_updated
signal connection_succeeded
signal connection_failed
signal server_disconnected_signal

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_dedicated_server(port: int = DEFAULT_PORT) -> bool:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PLAYERS)
	if error != OK:
		print("Failed to start server: ", error)
		return false
	multiplayer.multiplayer_peer = peer
	print("Khairagarh Battle Server started on port: ", port)
	return true

func join_game(ip: String, port: int, user_name: String, code: String) -> void:
	server_ip = ip
	server_port = port
	player_name = user_name
	room_code = code.to_upper().strip_edges()
	
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, server_port)
	if err != OK:
		emit_signal("connection_failed")
		return
	multiplayer.multiplayer_peer = peer

func _on_connected_to_server() -> void:
	var my_id = multiplayer.get_unique_id()
	rpc_id(1, "server_register_player", my_id, player_name, room_code)
	emit_signal("connection_succeeded")

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	emit_signal("connection_failed")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	emit_signal("server_disconnected_signal")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
	if multiplayer.is_server():
		if players.has(id):
			var left_room = players[id]["room"]
			players.erase(id)
			rpc("client_update_player_list", players)
			rpc("client_broadcast_feed", str(id) + " disconnected")

# --- SERVER RPCs (Authoritative) ---
@rpc("any_peer", "call_local", "reliable")
func server_register_player(id: int, p_name: String, r_code: String) -> void:
	if not multiplayer.is_server():
		return
	players[id] = {
		"name": p_name,
		"kills": 0,
		"deaths": 0,
		"score": 0,
		"room": r_code,
		"health": 100
	}
	rpc("client_update_player_list", players)
	rpc("client_broadcast_feed", p_name + " joined Khairagarh!")

@rpc("any_peer", "call_local", "reliable")
func server_request_hit(target_id: int, damage: int, weapon_name: String) -> void:
	if not multiplayer.is_server():
		return
	var attacker_id = multiplayer.get_remote_sender_id()
	if not players.has(target_id):
		return
	
	var target_data = players[target_id]
	target_data["health"] -= damage
	
	if target_data["health"] <= 0:
		target_data["health"] = 100
		target_data["deaths"] += 1
		if players.has(attacker_id):
			players[attacker_id]["kills"] += 1
			players[attacker_id]["score"] += 100
			rpc("client_broadcast_feed", players[attacker_id]["name"] + " eliminated " + target_data["name"] + " with " + weapon_name)
		rpc("client_player_respawn", target_id)
	
	rpc("client_sync_health", target_id, target_data["health"])
	rpc("client_update_player_list", players)

# --- CLIENT RPCs ---
@rpc("authority", "call_local", "reliable")
func client_update_player_list(new_players: Dictionary) -> void:
	players = new_players
	emit_signal("player_list_updated")

@rpc("authority", "call_local", "reliable")
func client_sync_health(id: int, hp: int) -> void:
	var scene_root = get_tree().current_scene
	if scene_root and scene_root.has_node("Players/" + str(id)):
		var p = scene_root.get_node("Players/" + str(id))
		p.current_hp = hp
		if id == multiplayer.get_unique_id():
			scene_root.get_node("UI/HUD").set_health(hp)

@rpc("authority", "call_local", "reliable")
func client_player_respawn(id: int) -> void:
	var scene_root = get_tree().current_scene
	if scene_root and scene_root.has_node("Players/" + str(id)):
		var p = scene_root.get_node("Players/" + str(id))
		p.respawn()

@rpc("authority", "call_local", "reliable")
func client_broadcast_feed(msg: String) -> void:
	var scene_root = get_tree().current_scene
	if scene_root and scene_root.has_node("UI/HUD"):
		scene_root.get_node("UI/HUD").add_feed(msg)
