extends Control

var _player_name = ''
var _server_ip = ''
onready var _server_port = Network.DEFAULT_PORT

func _ready():
    if Network.IS_SERVER:
        Network.create_server()
        _load_game()
    else:
        var text_field = get_node('VBoxContainer/Server/TextField')
        text_field.text = Network.DEFAULT_IP + ":" + str(Network.DEFAULT_PORT)

func _on_Name_TextField_text_changed(new_text):
    _player_name = new_text

func _on_Server_TextField_text_changed(new_text):
    if new_text.find(':') != -1:
        var parts = new_text.split(':')
        _server_ip = parts[0]
        _server_port = int(parts[1])
    else:
        _server_ip = new_text
        _server_port = Network.DEFAULT_PORT

func _on_JoinButton_pressed():
    if _player_name == '':
        return
    if _server_ip == '':
        return
    Network.connect_to_server(_server_ip, _server_port, _player_name)
    _load_game()

func _load_game():
    get_tree().change_scene('res://Game.tscn')
