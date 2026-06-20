extends Control

const PANEL_LEFT := 1290.0
const PANEL_TOP := 72.0
const PANEL_RIGHT := 1590.0
const PANEL_BOTTOM := 690.0
const SCROLL_MIN_HEIGHT := 500.0

var embedded_in_sidebar: bool = false

@onready var panel_container: PanelContainer = $PanelContainer
@onready var root_vbox: VBoxContainer = $PanelContainer/VBoxContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $PanelContainer/VBoxContainer/DescriptionLabel
@onready var policy_label: Label = $PanelContainer/VBoxContainer/PolicyLabel
@onready var toggle_slime_gel_button: Button = $PanelContainer/VBoxContainer/ToggleSlimeGelButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var current_building_id: String = ""
var current_building_node: Node = null
var current_town_node: Node = null

var detail_scroll: ScrollContainer = null
var detail_content_vbox: VBoxContainer = null

var identity_section_label: Label = null
var capacity_section_label: Label = null
var service_section_label: Label = null
var worker_section_label: Label = null
var upgrade_section_label: Label = null
var policy_section_label: Label = null
var guild_hall_section_label: Label = null
var guild_registry_section_label: Label = null
var placement_section_label: Label = null

var worker_button_row: HBoxContainer = null
var add_worker_button: Button = null
var remove_worker_button: Button = null
var upgrade_button: Button = null
var toggle_visitor_intake_button: Button = null
var mark_favorite_button: Button = null
var priority_return_button: Button = null
var contract_resident_button: Button = null

func _ready() -> void:
    _configure_panel_size()
    toggle_slime_gel_button.pressed.connect(_on_toggle_slime_gel_pressed)
    close_button.pressed.connect(_on_close_pressed)
    _create_scrollable_detail_layout()
    GameState.state_changed.connect(_refresh)
    visible = false

func set_embedded_in_sidebar(value: bool) -> void:
    embedded_in_sidebar = value
    _configure_panel_size()

func _configure_panel_size() -> void:
    if panel_container == null:
        return

    if embedded_in_sidebar:
        panel_container.set_anchors_preset(Control.PRESET_FULL_RECT)
        panel_container.offset_left = 0.0
        panel_container.offset_top = 0.0
        panel_container.offset_right = 0.0
        panel_container.offset_bottom = 0.0
        panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        panel_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
        panel_container.custom_minimum_size = Vector2(0, 0)
        return

    panel_container.offset_left = PANEL_LEFT
    panel_container.offset_top = PANEL_TOP
    panel_container.offset_right = PANEL_RIGHT
    panel_container.offset_bottom = PANEL_BOTTOM
    panel_container.custom_minimum_size = Vector2(PANEL_RIGHT - PANEL_LEFT, PANEL_BOTTOM - PANEL_TOP)

func _create_scrollable_detail_layout() -> void:
    description_label.visible = false
    policy_label.visible = false
    toggle_slime_gel_button.visible = false

    title_label.text = "Building Details"
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    detail_scroll = ScrollContainer.new()
    detail_scroll.name = "DetailScroll"
    detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_scroll.custom_minimum_size = Vector2(0, SCROLL_MIN_HEIGHT)
    root_vbox.add_child(detail_scroll)
    root_vbox.move_child(detail_scroll, close_button.get_index())

    detail_content_vbox = VBoxContainer.new()
    detail_content_vbox.name = "DetailContentVBox"
    detail_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_scroll.add_child(detail_content_vbox)

    identity_section_label = _create_section_label("IdentitySectionLabel")
    detail_content_vbox.add_child(identity_section_label)

    placement_section_label = _create_section_label("PlacementSectionLabel")
    detail_content_vbox.add_child(placement_section_label)

    capacity_section_label = _create_section_label("CapacitySectionLabel")
    detail_content_vbox.add_child(capacity_section_label)

    service_section_label = _create_section_label("ServiceSectionLabel")
    detail_content_vbox.add_child(service_section_label)

    worker_section_label = _create_section_label("WorkerSectionLabel")
    detail_content_vbox.add_child(worker_section_label)

    worker_button_row = HBoxContainer.new()
    worker_button_row.name = "WorkerButtonRow"
    worker_button_row.visible = false
    worker_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_content_vbox.add_child(worker_button_row)

    add_worker_button = Button.new()
    add_worker_button.name = "AddWorkerButton"
    add_worker_button.text = "+ Worker"
    add_worker_button.visible = true
    add_worker_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_worker_button.pressed.connect(_on_add_worker_pressed)
    worker_button_row.add_child(add_worker_button)

    remove_worker_button = Button.new()
    remove_worker_button.name = "RemoveWorkerButton"
    remove_worker_button.text = "- Worker"
    remove_worker_button.visible = true
    remove_worker_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    remove_worker_button.pressed.connect(_on_remove_worker_pressed)
    worker_button_row.add_child(remove_worker_button)

    upgrade_section_label = _create_section_label("UpgradeSectionLabel")
    detail_content_vbox.add_child(upgrade_section_label)

    upgrade_button = Button.new()
    upgrade_button.name = "UpgradeButton"
    upgrade_button.text = "Upgrade Building"
    upgrade_button.visible = false
    upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    upgrade_button.pressed.connect(_on_upgrade_pressed)
    detail_content_vbox.add_child(upgrade_button)

    guild_hall_section_label = _create_section_label("GuildHallSectionLabel")
    detail_content_vbox.add_child(guild_hall_section_label)

    toggle_visitor_intake_button = Button.new()
    toggle_visitor_intake_button.name = "ToggleVisitorIntakeButton"
    toggle_visitor_intake_button.text = "Toggle Visitor Intake"
    toggle_visitor_intake_button.visible = false
    toggle_visitor_intake_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    toggle_visitor_intake_button.pressed.connect(_on_toggle_visitor_intake_pressed)
    detail_content_vbox.add_child(toggle_visitor_intake_button)

    guild_registry_section_label = _create_section_label("GuildRegistrySectionLabel")
    detail_content_vbox.add_child(guild_registry_section_label)

    mark_favorite_button = Button.new()
    mark_favorite_button.name = "MarkFavoriteButton"
    mark_favorite_button.text = "Toggle Favorite Placeholder"
    mark_favorite_button.visible = false
    mark_favorite_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mark_favorite_button.pressed.connect(_on_mark_favorite_pressed)
    detail_content_vbox.add_child(mark_favorite_button)

    priority_return_button = Button.new()
    priority_return_button.name = "PriorityReturnButton"
    priority_return_button.text = "Mark Priority Return"
    priority_return_button.visible = false
    priority_return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    priority_return_button.pressed.connect(_on_priority_return_pressed)
    detail_content_vbox.add_child(priority_return_button)

    contract_resident_button = Button.new()
    contract_resident_button.name = "ContractResidentButton"
    contract_resident_button.text = "Contract Favorite Placeholder"
    contract_resident_button.visible = false
    contract_resident_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    contract_resident_button.pressed.connect(_on_contract_resident_pressed)
    detail_content_vbox.add_child(contract_resident_button)

    policy_section_label = _create_section_label("PolicySectionLabel")
    detail_content_vbox.add_child(policy_section_label)

    root_vbox.remove_child(toggle_slime_gel_button)
    toggle_slime_gel_button.text = "Toggle Slime Gel"
    toggle_slime_gel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_content_vbox.add_child(toggle_slime_gel_button)

    close_button.text = "Close Building Details"

func _create_section_label(label_name: String) -> Label:
    var label := Label.new()
    label.name = label_name
    label.visible = false
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return label

func open_for_building(building_id: String, building_node: Node = null, town_node: Node = null) -> void:
    current_building_id = building_id
    current_building_node = building_node
    current_town_node = town_node
    visible = true
    _configure_panel_size()
    _refresh()

    if detail_scroll != null:
        detail_scroll.scroll_vertical = 0

func close() -> void:
    visible = false
    current_building_id = ""
    current_building_node = null
    current_town_node = null

func _refresh() -> void:
    var has_valid_building: bool = current_building_node != null and is_instance_valid(current_building_node)
    var has_town: bool = current_town_node != null and is_instance_valid(current_town_node)

    _refresh_title(has_valid_building)
    _refresh_identity_section(has_town, has_valid_building)
    _refresh_placement_section(has_town, has_valid_building)
    _refresh_capacity_section(has_town, has_valid_building)
    _refresh_service_section(has_town, has_valid_building)
    _refresh_worker_section(has_town, has_valid_building)
    _refresh_upgrade_section(has_town, has_valid_building)
    _refresh_guild_hall_section(has_town, has_valid_building)
    _refresh_guild_registry_section(has_town, has_valid_building)
    _refresh_policy_section(has_town, has_valid_building)

func _refresh_title(has_valid_building: bool) -> void:
    if not has_valid_building:
        title_label.text = "Building Details"
        return

    if current_building_id == "general_store":
        title_label.text = "General Store"
    elif current_building_id == "inn":
        title_label.text = "Inn"
    elif current_building_id == "guild_hall":
        title_label.text = "Guild Hall"
    else:
        title_label.text = current_building_id.capitalize()

func _refresh_identity_section(has_town: bool, has_valid_building: bool) -> void:
    if identity_section_label == null:
        return

    var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_identity_summary")
    identity_section_label.visible = can_show

    if can_show:
        identity_section_label.text = "IDENTITY\n%s" % current_town_node.get_building_identity_summary(current_building_node)

func _refresh_placement_section(has_town: bool, has_valid_building: bool) -> void:
    if placement_section_label == null:
        return

    var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_placement_summary")
    placement_section_label.visible = can_show

    if can_show:
        placement_section_label.text = "PLACEMENT\n%s" % current_town_node.get_building_placement_summary(current_building_node)

func _refresh_capacity_section(has_town: bool, has_valid_building: bool) -> void:
    if capacity_section_label == null:
        return

    var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_capacity_queue_summary")
    capacity_section_label.visible = can_show

    if can_show:
        capacity_section_label.text = "CAPACITY / QUEUE\n%s" % current_town_node.get_building_capacity_queue_summary(current_building_node)

func _refresh_service_section(has_town: bool, has_valid_building: bool) -> void:
    if service_section_label == null:
        return

    var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_service_summary")
    service_section_label.visible = can_show

    if can_show:
        service_section_label.text = "SERVICE\n%s" % current_town_node.get_building_service_summary(current_building_node)

func _refresh_worker_section(has_town: bool, has_valid_building: bool) -> void:
    if worker_section_label == null:
        return

    var can_show_summary: bool = has_town and has_valid_building and current_town_node.has_method("get_building_worker_summary")
    worker_section_label.visible = can_show_summary

    if can_show_summary:
        worker_section_label.text = "WORKERS\n%s" % current_town_node.get_building_worker_summary(current_building_node)

    var can_adjust_workers: bool = has_town and has_valid_building and current_town_node.has_method("can_adjust_building_workers") and bool(current_town_node.can_adjust_building_workers(current_building_node))

    if worker_button_row != null:
        worker_button_row.visible = can_adjust_workers

func _refresh_upgrade_section(has_town: bool, has_valid_building: bool) -> void:
    if upgrade_section_label == null:
        return

    var can_show_summary: bool = has_town and has_valid_building and current_town_node.has_method("get_building_upgrade_summary")
    upgrade_section_label.visible = can_show_summary

    if can_show_summary:
        upgrade_section_label.text = "UPGRADES\n%s" % current_town_node.get_building_upgrade_summary(current_building_node)

    var can_upgrade: bool = has_town and has_valid_building and current_town_node.has_method("can_upgrade_building") and bool(current_town_node.can_upgrade_building(current_building_node))

    if upgrade_button != null:
        upgrade_button.visible = can_upgrade

func _refresh_guild_hall_section(has_town: bool, has_valid_building: bool) -> void:
    if guild_hall_section_label == null:
        return

    var show_guild_hall_section: bool = has_town and has_valid_building and current_building_id == "guild_hall" and current_town_node.has_method("get_guild_hall_visitor_cap_summary")

    guild_hall_section_label.visible = show_guild_hall_section

    if toggle_visitor_intake_button != null:
        toggle_visitor_intake_button.visible = show_guild_hall_section
        toggle_visitor_intake_button.text = "Toggle Intake (%s)" % GameState.get_visitor_intake_policy_text()

    if show_guild_hall_section:
        guild_hall_section_label.text = "GUILD HALL / VISITOR INTAKE\n%s" % current_town_node.get_guild_hall_visitor_cap_summary(current_building_node)

func _refresh_guild_registry_section(has_town: bool, has_valid_building: bool) -> void:
    if guild_registry_section_label == null:
        return

    var show_registry: bool = has_town and has_valid_building and current_building_id == "guild_hall" and current_town_node.has_method("get_guild_hall_registry_summary")

    guild_registry_section_label.visible = show_registry

    if mark_favorite_button != null:
        mark_favorite_button.visible = show_registry

    if priority_return_button != null:
        priority_return_button.visible = show_registry

    if contract_resident_button != null:
        contract_resident_button.visible = show_registry

    if show_registry:
        guild_registry_section_label.text = "GUILD REGISTRY PLACEHOLDER\n%s" % current_town_node.get_guild_hall_registry_summary(current_building_node)

func _refresh_policy_section(has_town: bool, has_valid_building: bool) -> void:
    if policy_section_label == null:
        return

    var show_general_store_policy: bool = has_valid_building and current_building_id == "general_store"

    policy_section_label.visible = show_general_store_policy
    toggle_slime_gel_button.visible = show_general_store_policy

    if show_general_store_policy:
        policy_section_label.text = "POLICY\nSlime Gel buying: %s" % GameState.get_general_store_buy_policy_text()
        toggle_slime_gel_button.text = "Toggle Slime Gel (%s)" % GameState.get_general_store_buy_policy_text()

func _on_contract_resident_pressed() -> void:
    if current_building_id == "guild_hall" and current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("contract_first_eligible_favorite_from_guild_hall"):
        current_town_node.contract_first_eligible_favorite_from_guild_hall()
        _refresh()

func _on_mark_favorite_pressed() -> void:
    if current_building_id == "guild_hall" and current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("toggle_favorite_known_adventurer_from_guild_hall"):
        current_town_node.toggle_favorite_known_adventurer_from_guild_hall()
        _refresh()

func _on_priority_return_pressed() -> void:
    if current_building_id == "guild_hall" and current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("mark_priority_return_from_guild_hall"):
        current_town_node.mark_priority_return_from_guild_hall()
        _refresh()

func _on_toggle_visitor_intake_pressed() -> void:
    if current_building_id == "guild_hall" and current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("toggle_visitor_intake_from_guild_hall"):
        current_town_node.toggle_visitor_intake_from_guild_hall()
        _refresh()

func _on_toggle_slime_gel_pressed() -> void:
    if current_building_id == "general_store":
        GameState.toggle_general_store_buys_slime_gel()
        _refresh()

func _on_add_worker_pressed() -> void:
    if current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("adjust_building_worker_count"):
        current_town_node.adjust_building_worker_count(current_building_node, 1)
        _refresh()

func _on_remove_worker_pressed() -> void:
    if current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("adjust_building_worker_count"):
        current_town_node.adjust_building_worker_count(current_building_node, -1)
        _refresh()

func _on_upgrade_pressed() -> void:
    if current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("upgrade_building"):
        current_town_node.upgrade_building(current_building_node)
        _refresh()

func _on_close_pressed() -> void:
    close()
