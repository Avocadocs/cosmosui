module cosmosui

import gg
import gx

const button_bg_color = gx.hex(0x4dabf7)
const button_border_color = gx.hex(0x495057)
const button_text_color = gx.hex(0xf1f3f5)
const button_hover_color = gx.hex(0xadb5bd)
const button_pressed_color = gx.hex(0xdee2e6)

pub enum ButtonState {
	normal
	hovered
	pressed
	disabled
}

type ButtonFn = fn (&Button)

@[heap]
pub struct Button {
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
	text          string
	state         ButtonState = .normal
	on_click      ButtonFn    = unsafe { nil }
	parent        &Window     = unsafe { nil }
	bg_color      gx.Color
	text_color    gx.Color
	hover_color   gx.Color
	pressed_color gx.Color
	border_color  gx.Color
}

pub struct ButtonParams {
pub:
	id            string
	x             int
	y             int
	width         int
	height        int
	z_index       int
	text          string
	disabled      bool
	on_click      ButtonFn = unsafe { nil }
	bg_color      gx.Color = cosmosui.button_bg_color
	text_color    gx.Color = cosmosui.button_text_color
	hover_color   gx.Color = cosmosui.button_hover_color
	pressed_color gx.Color = cosmosui.button_pressed_color
	border_color  gx.Color = cosmosui.button_border_color
}

pub fn button(c ButtonParams) &Button {
	return &Button{
		id: c.id
		x: c.x
		y: c.y
		width: c.width
		height: c.height
		z_index: c.z_index
		text: c.text
		on_click: c.on_click
		bg_color: c.bg_color
		text_color: c.text_color
		hover_color: c.hover_color
		pressed_color: c.pressed_color
		border_color: c.border_color
	}
}

pub fn (b Button) point_inside(x f32, y f32) bool {
	return x >= b.x && x <= b.x + b.width && y >= b.y && y <= b.y + b.height
}

pub fn (mut b Button) set_text(text string) {
	b.text = text
}

pub fn (b Button) draw(mut ctx gg.Context) {
	btn_color := match b.state {
		.normal {
			b.bg_color
		}
		.hovered {
			b.hover_color
		}
		.pressed {
			b.pressed_color
		}
		.disabled {
			gx.hex(0xadb5bd)
		}
	}

	ctx.draw_rect_filled(b.x, b.y, b.width, b.height, btn_color)
	ctx.draw_rect_empty(b.x, b.y, b.width, b.height, b.border_color)

	bcenter_x := b.x + b.width / 2
	bcenter_y := b.y + b.height / 2

	ctx.draw_text(bcenter_x, bcenter_y, b.text, gx.TextCfg{
		size: 16
		color: b.text_color
		align: gx.HorizontalAlign.center
		vertical_align: gx.VerticalAlign.middle
	})
}

fn (mut b Button) init(w &Window) {
	b.parent = w
	mut sub := w.eventbus.subscriber
	if b.disabled {
		return
	}
	sub.subscribe_method('mouse_down', btn_click, b)
	sub.subscribe_method('mouse_move', btn_hover, b)
}

fn btn_click(mut b Button, e &gg.Event, w &Window) {
	if b.point_inside(e.mouse_x, e.mouse_y) {
		if b.on_click != unsafe { nil } {
			b.on_click(b)
		}
	}
}

fn btn_hover(mut b Button, e &gg.Event, w &Window) {
	if b.point_inside(e.mouse_x, e.mouse_y) {
		b.state = .hovered
	} else {
		b.state = .normal
	}
}
