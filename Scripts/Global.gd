tool
extends Node


enum SelectorState {
	NONE,
	HOVERED,
	SELECTED,
	CLICKED,
}
enum BuildingState {
	PLACING,
	IDLE,
	OPERATING,
}
enum ResourceType {
	FUEL,
	METAL,
}
enum BuildingID {
	UNKNOWN = -1,
	GENERATOR,
	BASIC_CANNON,
}

const CELL_SIZE = Vector3(2, 0, 2)
const DEFAULT_BUILDING_HEIGHT = -0.8
const BUILDINGS = {
	BuildingID.UNKNOWN: {
		"name": "??????",
		"description": "??????",
		"scene": "",
		"icon": preload("res://Assets/Images/Icons/BuildingPortraits/question.png"),
		"metal": 0,
		"fuel": 0,
		"energy_required": 0,
		"energy_produced": 0,
		"range": 0,
		"damage": 0,
		"cooldown": 0,
	},
	BuildingID.GENERATOR: {
		"name": "Generator",
		"description": "Simple Energy Generator",
		"scene": preload("res://Scenes/Buildings/Generator.tscn"),
		"icon": preload("res://Assets/Images/Icons/BuildingPortraits/machine_generatorLarge_NW.png"),
		"metal": 120,
		"fuel": 100,
		"energy_required": 0,
		"energy_produced": 10,
		"range": 1,
		"damage": 0,
		"cooldown": 0,
	},
	BuildingID.BASIC_CANNON: {
		"name": "Basic Cannon",
		"description": "A Basic Cannon to handle the asteroid",
		"scene": preload("res://Scenes/Buildings/BasicCannon.tscn"),
		"icon": preload("res://Assets/Images/Icons/BuildingPortraits/turret_single_SW.png"),
		"metal": 200,
		"fuel": 80,
		"energy_required": 10,
		"energy_produced": 0,
		"range": 200000,
		"damage": 150,
		"cooldown": 5,
	},
}
const NONE_CONFIG = {
	"scan_color": Color(0, 0, 0),
	"scan_line_width": 0,
	"scan_line_size": 0,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0, 0, 0),
}
const RES_HOVERED_CONFIG = {
	"scan_color": Color(0.078431, 1, 1),
	"scan_line_width": 0.6,
	"scan_line_size": 0.2,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, -0.3, 0.3),
}
const RES_SELECTED_CONFIG = {
	"scan_color": Color(0.053436, 0.100389, 0.804688),
	"scan_line_width": 0.3,
	"scan_line_size": 0.2,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.1, -0.1, 0.1),
}
const RES_CLICKED_CONFIG = {
	"scan_color": Color(1, 1, 0),
	"scan_line_width": 0.6,
	"scan_line_size": 0.2,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, -0.3, 0.3),
}
const CELL_HOVERED_CONFIG = {
	"scan_color": Color(0.078431, 1, 1),
	"scan_line_width": 0.5,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, 0.2, 0.3),
}
const CELL_SELECTED_CONFIG = {
	"scan_color": Color(0.053436, 0.100389, 0.804688),
	"scan_line_width": 0.6,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, -0.2, 0.3),
}
const CELL_CLICKED_CONFIG = {
	"scan_color": Color(1, 1, 0),
	"scan_line_width": 0.5,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, 0.2, 0.3),
}
const BUILDING_HOVERED_CONFIG = {
	"scan_color": Color(0.078431, 1, 1),
	"scan_line_width": 0.5,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, 0.2, 0.3),
}
const BUILDING_SELECTED_CONFIG = {
	"scan_color": Color(0.053436, 0.100389, 0.804688),
	"scan_line_width": 0.6,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, -0.2, 0.3),
}
const BUILDING_PLACING_ALLOW_CONFIG = {
	"scan_color": Color(0, 1, 0.085938),
	"scan_line_width": 0.7,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, 0.2, 0.3),
}
const BUILDING_PLACING_DENY_CONFIG = {
	"scan_color": Color(1, 0, 0),
	"scan_line_width": 0.7,
	"scan_line_size": 0.3,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, 0.2, 0.3),
}
