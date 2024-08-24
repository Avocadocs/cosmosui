module cosmosui

import gg

pub interface Widget {
mut:
	id       string
	x        int
	y        int
	x_offset int
	y_offset int
	width    int
	height   int
	z_index  int
	hidden   bool
	// parent // TO DO
	point_inside(x f32, y f32) bool
	draw(mut ctx gg.Context)
	init(w &Window)
	// delete()
}

pub fn (mut w Widget) set_pos(x int, y int) {
	w.x = x
	w.y = y
}
