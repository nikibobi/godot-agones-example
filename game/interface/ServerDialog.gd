extends ConfirmationDialog

export(String) var label_text = 'Text'

var text
var password

func _ready():
    $'GridContainer/TextLabel'.text = label_text

func clear(root = self):
    for node in root.get_children():
        if node is LineEdit:
            node.clear()
        if node.get_child_count() > 0:
            clear(node)

func show():
    clear()
    popup_centered()

func _on_NameEdit_text_changed(new_text):
    text = new_text

func _on_PasswordEdit_text_changed(new_text):
    password = new_text
