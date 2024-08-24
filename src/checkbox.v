module cosmosui

import gg
import gx

const checkbox_bg_color = gx.hex(0x343a40)
const checkbox_text_color = gx.hex(0xf1f3f5)
const checkbox_accent_color = gx.hex(0x868e96)

@[heap]
pub struct Checkbox {
pub mut:
	id           string
	x            int
	y            int
	x_offset	 int
	y_offset	 int
	width        int
	height       int
	z_index	  int
	x_offset	 int
	y_offset	      int
	hidden       bool
	disabled     bool
	parent       &Window = unsafe { nil }
	checked      bool
	text         string
	bg_color     gx.Color
	text_color   gx.Color
	accent_color gx.Color
}

pub struct CheckboxParams {
pub:
	id           string
	x            int
	y            int
	width        int = 20
	height       int = 20
	z_index      int
	hidden bool
	disabled bool
	checked      bool
	text         string
	bg_color     gx.Color = cosmosui.checkbox_bg_color
	text_color   gx.Color = cosmosui.checkbox_text_color
	accent_color gx.Color = cosmosui.checkbox_accent_color
}

pub fn checkbox(c CheckboxParams) &Checkbox {
	return &Checkbox{
		id: c.id
		x: c.x
		y: c.y
		width: c.width
		height: c.height
		z_index: c.z_index
		hidden: c.hidden
		disabled: c.disabled
		text: c.text
		checked: c.checked
		bg_color: c.bg_color
		text_color: c.text_color
		accent_color: c.accent_color
	}
}

pub fn (c Checkbox) point_inside(x f32, y f32) bool {
	return x >= c.x && x <= c.x + c.width && y >= c.y && y <= c.y + c.height
}

pub fn (c Checkbox) draw(mut ctx gg.Context) {
	if c.checked {
		ctx.draw_rect_filled(c.x, c.y, c.width, c.height, c.bg_color)
		ctx.draw_rect_filled(c.x + 4, c.y + 4, c.width - 8, c.height - 8, c.accent_color)
	} else {
		ctx.draw_rect_empty(c.x, c.y, c.width, c.height, c.bg_color)
	}
}

fn (mut c Checkbox) init(w &Window) {
	c.parent = w
	mut sub := w.eventbus.subscriber
	sub.subscribe_method('mouse_down', checkbox_click, c)
	sub.subscribe_method('mouse_move', checkbox_hover, c)
}

fn checkbox_click(mut c Checkbox, e &gg.Event, w &Window) {
	if c.point_inside(e.mouse_x, e.mouse_y) {
		c.checked = !c.checked
	}
}

fn checkbox_hover(mut c Checkbox, e &gg.Event, w &Window) {
	if c.point_inside(e.mouse_x, e.mouse_y) {
		// c.state = .hovered
	} else {
		// c.state = .normal
	}
}
