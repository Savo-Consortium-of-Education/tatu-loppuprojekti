extends Button

func _on_pressed() -> void:
    var menu = get_tree().get_first_node_in_group("upgrade_menu")
    if menu:
        menu.finish_upgrade()
