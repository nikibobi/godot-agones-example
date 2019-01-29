extends Tree

export(PoolStringArray) var column_titles

enum { COLUMN_NAME = 0, COLUMN_HOST = 1, COLUMN_PLAYERS = 2, COLUMN_LOCKED = 3 }

const RANDOM_ROWS = 60

func _ready():
	var root = create_item()
	add_column_titles(column_titles)
	add_rows(root)

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
	var host_name =  ip + ':' + str(port)
	var maximum = 5 + 5 * (randi() % 5)
	var current = randi() % (maximum + 1)
	var players = str(current) + '/' + str(maximum)
	var is_locked = randf() > 0.333
	return add_row(parent, server_name, host_name, players, is_locked)

func add_row(parent, server_name, host_name, players, is_locked):
	var row = create_item(parent)
	row.set_text(COLUMN_NAME, server_name)
	row.set_text(COLUMN_HOST, host_name)
	row.set_text_align(COLUMN_HOST, TreeItem.ALIGN_CENTER)
	row.set_text(COLUMN_PLAYERS, players)
	row.set_text_align(COLUMN_PLAYERS, TreeItem.ALIGN_CENTER)
	row.set_cell_mode(COLUMN_LOCKED, TreeItem.CELL_MODE_CHECK)
	row.set_checked(COLUMN_LOCKED, is_locked)
	return row

func _on_Connect_pressed():
	var row = get_selected()
	if row != null:
		var host = row.get_text(COLUMN_HOST)
		print('Connecting to ' + host)

func _on_Refresh_pressed():
	print('Refreshing')
