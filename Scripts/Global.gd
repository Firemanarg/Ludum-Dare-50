extends Node


enum SelectorState {
	NONE,
	HOVERED,
	SELECTED,
	CLICKED,
}

enum ResourceType {
	FUEL,
	METAL,
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

