extends Node

signal host_created()

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer: SteamMultiplayerPeer


func _ready() -> void:
	Steam.initRelayNetworkAccess() #initialize GodotSteam network access
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func host_lobby() -> void:
	# Will cause the "lobby_created" and "lobby_joined" signals to emit
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS)


# Called after creating a lobby locally
# Parameters borrowed from "Steam.lobby_created" signal
func on_lobby_created(connect: int, lobby_id: int) -> void:
	# We created the lobby, so we act as server host
	# Create a new peer
	if connect == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()


# Called when joining a lobby (includes host)
func on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# If we created the lobby, we are already hosting, so we should not create a new client peer
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		# If we did not create the lobby, proceed to create a new peer
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer


# Called when attempting to join from the Steam interface
func on_join_requested(lobby_id: int, steam_id: int) -> void:
	# Will cause the "lobby_joined" signal to emit
	Steam.joinLobby(lobby_id)
