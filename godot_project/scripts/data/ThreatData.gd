extends Resource
class_name ThreatData

@export var id: String = ""
@export var display_name: String = ""
@export var threat_type: String = ""
@export var danger_level: int = 1
@export var growth: int = 0
@export var status: String = "dormant"
@export_multiline var description: String = ""
