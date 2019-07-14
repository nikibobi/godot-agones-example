extends Tree

export(PoolStringArray) var column_titles
export(String) var master_server = 'http://192.168.2.203:30941'
export(String) var api_path = '/api/servers'

var query_params = {}

enum { COLUMN_NAME = 0, COLUMN_PLAYERS = 1, COLUMN_LOCKED = 2 }

onready var create_dialog = $'../../CreateDialog'
onready var connect_dialog = $'../../ConnectDialog'

func _ready():
    if Network.IS_SERVER:
        Network.create_server()
        get_tree().change_scene('res://Game.tscn')
    else:
        create_item()
        add_column_titles(column_titles)
        refresh()

func add_column_titles(titles):
    columns = titles.size()
    for i in range(columns):
        set_column_title(i, titles[i])
    set_column_titles_visible(true)

func add_row(parent, server_name, ip, port, current, maximum, password_hash = ''):
    var row = create_item(parent)
    row.set_text(COLUMN_NAME, server_name)
    row.set_meta('ip', ip)
    row.set_meta('port', port)
    var players = str(current) + '/' + str(maximum)
    row.set_text(COLUMN_PLAYERS, players)
    row.set_text_align(COLUMN_PLAYERS, TreeItem.ALIGN_CENTER)
    row.set_cell_mode(COLUMN_LOCKED, TreeItem.CELL_MODE_CHECK)
    row.set_checked(COLUMN_LOCKED, password_hash != '')
    row.set_meta('password_hash', password_hash)
    return row

func add_row_dict(parent, d):
    add_row(parent, d['name'], d['ipAddress'], d['port'], d['currentPlayers'], d['maxPlayers'], d['passwordHash'])

func refresh():
    var url = master_server + api_path
    var query = HTTPClient.new().query_string_from_dict(query_params)
    if query != '':
        url += '?' + query
    $HTTPRequest.request(url, [], false, HTTPClient.METHOD_GET)
    print('Fetch ' + url)

func _on_Refresh_pressed():
    refresh()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
    var body_text = body.get_string_from_utf8()
    var response = JSON.parse(body_text)
    var variant = response.result
    if typeof(variant) == TYPE_ARRAY:
        clear()
        var root = create_item()
        for server in variant:
            add_row_dict(root, server)
    elif typeof(variant) == TYPE_DICTIONARY:
        add_row_dict(get_root(), variant)

func change_params(key, pressed):
    if pressed:
        query_params[key] = true
    else:
        query_params.erase(key)

func connect_to_server(ip, port, player_name):
    Network.connect_to_server(ip, port, player_name)
    print('Connecting to ' + ip + ':' + str(port))
    get_tree().change_scene('res://Game.tscn')

func _on_HideFull_toggled(checked):
    change_params('isNotFull', checked)

func _on_HideEmpty_toggled(checked):
    change_params('isNotEmpty', checked)

func _on_HideLocked_toggled(checked):
    change_params('isNotPasswordProtected', checked)

func _on_Create_pressed():
    create_dialog.show()

func _on_Connect_pressed():
    if get_selected() == null:
        return
    connect_dialog.show()

func _on_CreateDialog_confirmed():
    var url = master_server + api_path
    var headers = PoolStringArray(['Content-Type: application/json'])
    var name = create_dialog.text
    var password = create_dialog.password
    var payload = {
        'name': name,
        'currentPlayers': 0,
        'maxPlayers': 5
    }
    if not password.empty():
        payload['passwordHash'] = password.sha256_text()
    $HTTPRequest.request(url, headers, false, HTTPClient.METHOD_POST, JSON.print(payload))

func _on_ConnectDialog_confirmed():
    var row = get_selected()
    if row == null:
        return
    var ip = row.get_meta('ip')
    var port = row.get_meta('port')
    var player_name = connect_dialog.text
    if row.is_checked(COLUMN_LOCKED):
        var password_hash = connect_dialog.password.sha256_text()
        if password_hash == row.get_meta('password_hash'):
            connect_to_server(ip, port, player_name)
        else:
            print('wrong password')
    else:
        connect_to_server(ip, port, player_name)
