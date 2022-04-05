extends Spatial
class_name CellGrid


var cells: Array = []


func _ready():
	init_cells_array()


func init_cells_array():
	var row_index = 0

	cells.clear()
	for row in get_children():
		cells.append([])
		for cell in row.get_children():
			cells[row_index].append(cell)
			cell.building = null
		row_index += 1


func set_visual_config(row: int, col: int, config: Dictionary):
	var cell: Cell = get_child(row).get_child(col)
	cell.set_visual_config(config)
