module cosmosui

import gg
import gx

const input_bg_color = gx.hex(0x343a40)
const input_border_color = gx.hex(0x495057)
const input_text_color = gx.hex(0xf1f3f5)
const input_focused_color = gx.hex(0x868e96)

@[heap]
pub struct Input {
pub mut:
	id            string
	x             int
	y             int
	x_offset      int
	y_offset      int
	width         int
	height        int
	z_index       int
	hidden        bool
	disabled      bool
	focused       bool
	parent        &Window = unsafe { nil }
	text          string
	bg_color      gx.Color
	border_color  gx.Color
	text_color    gx.Color
	focused_color gx.Color
}

pub struct InputParams {
pub:
	id            string
	x             int
	y             int
	width         int
	height        int
	z_index       int
	disabled      bool
	focused       bool
	text          string
	bg_color      gx.Color = cosmosui.input_bg_color
	border_color  gx.Color = cosmosui.input_border_color
	text_color    gx.Color = cosmosui.input_text_color
	focused_color gx.Color = cosmosui.input_focused_color
}

pub fn input(c InputParams) &Input {
	return &Input{
		id: c.id
		x: c.x
		y: c.y
		width: c.width
		height: c.height
		z_index: c.z_index
		text: c.text
		disabled: c.disabled
		bg_color: c.bg_color
		border_color: c.border_color
		text_color: c.text_color
		focused_color: c.focused_color
	}
}

pub fn (i Input) point_inside(x f32, y f32) bool {
	return x >= i.x && x <= i.x + i.width && y >= i.y && y <= i.y + i.height
}

pub fn (mut i Input) set_text(text string) {
	i.text = text
}

pub fn (i Input) draw(mut ctx gg.Context) {
	ctx.draw_rect_filled(i.x, i.y, i.width, i.height, i.bg_color)

	if i.focused {
		ctx.draw_rect_empty(i.x, i.y, i.width, i.height, i.focused_color)
	} else {
		ctx.draw_rect_empty(i.x, i.y, i.width, i.height, i.border_color)
	}

	ctx.draw_text(i.x + 5, i.y + 5, i.text, gx.TextCfg{
		size: 16
		color: i.text_color
	})
}

fn (mut i Input) init(w &Window) {
	i.parent = w
	mut sub := w.eventbus.subscriber
	sub.subscribe_method('char', input_type, i)
	sub.subscribe_method('mouse_down', input_click, i)
	sub.subscribe_method('key_down', input_key_down, i)
}

fn input_type(mut i Input, e &gg.Event, w &Window) {
	if i.focused {
		i.text += rune(e.char_code).str()
	}
}

fn input_click(mut i Input, e &gg.Event, w &Window) {
	i.focused = i.point_inside(e.mouse_x, e.mouse_y)
}

fn input_key_down(mut i Input, e &gg.Event, w &Window) {
	if i.focused {
		if e.key_code == gg.KeyCode.backspace {
			i.text = i.text[0..(i.text.len - 1)]
		}
	}
}
