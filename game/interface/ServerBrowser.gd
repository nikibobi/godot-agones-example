extends Tree

export(PoolStringArray) var column_titles
export(String) var master_server = 'http://192.168.2.203:30941'
export(String) var api_path = '/api/servers'

var params = {}

enum { COLUMN_NAME = 0, COLUMN_HOST = 1, COLUMN_PLAYERS = 2, COLUMN_LOCKED = 3 }

const RANDOM_ROWS = 60

func _ready():
	var root = create_item()
	add_column_titles(column_titles)
	refresh()

func add_column_titles(titles):
	columns = titles.size()
	for i in range(columns):
		set_column_title(i, titles[i])
	set_column_titles_visible(true)

func add_rows(parent):
	for i in range(RANDOM_ROWS):
		add_row_random(parent)

func add_row_random(parent):
	var server_name = 'Server ' + char(65 + randi() % 26)
	var ip = '192.168.2.203'
	var port = 7000 + randi() % 1001
	var maximum = 5 + 5 * (randi() % 5)
	var current = randi() % (maximum + 1)
	var is_locked = randf() > 0.333
	return add_row(parent, server_name, ip, port, current, maximum, is_locked)

func add_row(parent, server_name, ip, port, current, maximum, is_locked):
	var row = create_item(parent)
	row.set_text(COLUMN_NAME, server_name)
	var host_name =  ip + ':' + str(port)
	row.set_text(COLUMN_HOST, host_name)
	row.set_text_align(COLUMN_HOST, TreeItem.ALIGN_CENTER)
	var players = str(current) + '/' + str(maximum)
	row.set_text(COLUMN_PLAYERS, players)
	row.set_text_align(COLUMN_PLAYERS, TreeItem.ALIGN_CENTER)
	row.set_cell_mode(COLUMN_LOCKED, TreeItem.CELL_MODE_CHECK)
	row.set_checked(COLUMN_LOCKED, is_locked)
	return row

func refresh():
	var url = master_server + api_path
	var query = HTTPClient.new().query_string_from_dict(params)
	if query != '':
		url += '?' + query
	$HTTPRequest.request(url, [], false, HTTPClient.METHOD_GET)
	print(url)

func _on_Refresh_pressed():
	print('Refreshing')
	refresh()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if typeof(response.result) == TYPE_ARRAY:
		clear()
		var root = create_item()
		for s in response.result:
			add_row(root, s['name'], s['ipAddress'], s['port'], s['currentPlayers'], s['maxPlayers'], s['isPasswordProtected'])

func change_params(key, pressed):
	if pressed:
		params[key] = true
	else:
		params.erase(key)

func _on_HideFull_toggled(button_pressed):
	change_params('isNotFull', button_pressed)

func _on_HideEmpty_toggled(button_pressed):
	change_params('isNotEmpty', button_pressed)

func _on_HideLocked_toggled(button_pressed):
	change_params('isNotPasswordProtected', button_pressed)

func _on_Create_pressed():
	# TODO: show server create dialog
	print('Create')

func _on_Connect_pressed():
	var row = get_selected()
	if row == null:
		return
	var host = row.get_text(COLUMN_HOST)
	var parts = host.split(':')
	var ip = parts[0]
	var port = int(parts[1])
	# TODO: prompt for player name and server password
	var player_name = str(OS.get_unix_time()).sha256_text().substr(0, 6)
	Network.connect_to_server(ip, port, player_name)
	print('Connecting to ' + host)
	get_tree().change_scene('res://Game.tscn')