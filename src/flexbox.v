module cosmosui

import gg
import gx
import math { max }

pub enum FlexDirection {
	row
	row_reverse
	column
	column_reverse
}

// WIP not implemented yet
/*
pub enum AlignItems {
	stretch
	center
	start
	end
}

pub enum JustifyContent {
	flex_start
	flex_end
	center
	space_between
	space_around
}
*/

@[heap]
pub struct Flexbox {
pub mut:
	id             string
	x              int
	y              int
	width          int
	height         int
	z_index        int
	hidden        bool
	gap            int
	flex_direction FlexDirection
	// align_items AlignItems
	children              []Widget
	x_offset              int
	y_offset              int
	overflow              Overflow
	scrollview            &Scrollview = unsafe { nil }
	total_children_width  int
	total_children_height int
}

pub struct FlexboxParams {
pub:
	id             string
	x              int
	y              int
	width          int
	height         int
	z_index        int
	hidden       bool
	flex_direction FlexDirection = .row
	// align_items AlignItems = .start
	gap      int
	children []Widget
	overflow Overflow = .auto
}

pub fn flexbox(c FlexboxParams) &Flexbox {
	return &Flexbox{
		id: c.id
		x: c.x
		y: c.y
		width: c.width
		height: c.height
		z_index: c.z_index
		hidden: c.hidden
		flex_direction: c.flex_direction
		// align_items: c.align_items
		gap: c.gap
		children: c.children
	}
}

pub fn (f Flexbox) point_inside(x f32, y f32) bool {
	return x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
}

pub fn (mut f Flexbox) draw(mut ctx gg.Context) {
	ctx.scissor_rect(f.x, f.y, f.width, f.height)
	
	ctx.draw_rect_empty(f.x, f.y, f.width, f.height, gx.red)
	
	mut offset := match f.flex_direction {
		.row, .row_reverse {
			f.x
		}
		.column, .column_reverse {
			f.y
		}
	}

	if f.flex_direction == .row_reverse || f.flex_direction == .column_reverse {
		f.children.reverse_in_place()
	}

	mut scroll_y := 0
	mut scroll_x := 0

	if f.scrollview != unsafe { nil } {
		if f.scrollview.scrollbar_y {
			scroll_y = f.scrollview.scroll_y
		}
		if f.scrollview.scrollbar_x {
			scroll_x = f.scrollview.scroll_x
		}
	}

	for mut child in f.children {
		offset += f.gap
		if f.flex_direction == .row || f.flex_direction == .row_reverse {
			child.set_pos(offset - scroll_x, f.y - scroll_y)
		} else {
			child.set_pos(f.x - scroll_x, offset - scroll_y)
		}
		
		child.draw(mut ctx)
		if f.flex_direction == .row || f.flex_direction == .row_reverse {
			offset += child.width
		} else {
			offset += child.height
		}
	}

	if f.scrollview != unsafe { nil } {
		f.scrollview.draw(ctx)
	}

	ctx.scissor_rect(0, 0, ctx.width, ctx.height)
}

pub fn (mut f Flexbox) init(w &Window) {
	mut total_children_width := 0
	mut total_children_height := 0

	for mut child in f.children {
		child.init(w)

		if f.flex_direction == .row || f.flex_direction == .row_reverse {
			total_children_width += child.width
			total_children_height = max(total_children_height, child.height)
		} else {
			total_children_height += child.height
			total_children_width = max(total_children_width, child.width)
		}
	}

	f.total_children_width = total_children_width
	f.total_children_height = total_children_height

	if f.overflow == .clip {
		return
	}

	if f.total_children_width > f.width || f.total_children_height > f.height {
		f.scrollview = scrollview(
			layout: f
		)

		if f.total_children_height > f.height {
			f.scrollview.scrollbar_y = true
		}

		if f.total_children_width > f.width {
			f.scrollview.scrollbar_x = true
		}

		f.scrollview.init(w)
	}
}
