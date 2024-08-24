module cosmosui

import gg
import gx
import eventbus
import sokol.sapp

const window_bg_color = gx.hex(0x212529)

@[heap]
pub struct Window {
mut:
	ctx      gg.Context
	eventbus &eventbus.EventBus[string] = eventbus.new[string]()
pub mut:
	width    int
	height   int
	title    string
	bg_color gx.Color
	children []Widget
}

pub struct WindowParams {
pub:
	width    int      = 600
	height   int      = 400
	title    string   = 'Cosmos UI Window'
	bg_color gx.Color = cosmosui.window_bg_color
	children []Widget
}

pub fn window(c WindowParams) &Window {
	mut window := &Window{
		width: c.width
		height: c.height
		title: c.title
		bg_color: c.bg_color
		children: c.children
	}

	mut ctx := gg.new_context(
		width: c.width
		height: c.height
		ui_mode: true
		enable_dragndrop: true
		bg_color: c.bg_color
		// event_fn:
		user_data: window
		window_title: c.title
		frame_fn: window.draw
		init_fn: window.init
		event_fn: on_event
	)

	window.ctx = ctx

	return window
}

pub fn (mut w Window) run() {
	w.ctx.run()
}

/*

pub fn (w Window) get_widget_by_id(id string) Widget {
	for
}


pub fn (w Window) get_widgets_by_class(class string) []Widget {
	found_widgets := []Widgets{}

	for widget in w.children {
		
	}

}

pub fn (w Window) resize(w int, h int) {
	
}*/

pub fn (mut w Window) init(mut ctx gg.Context) {
	for mut widget in w.children {
		widget.init(w)
	}
}

pub fn on_event(e &gg.Event, mut window Window) {
	match e.typ {
		.mouse_down {
			window.handle_mouse_down(e)
		}
		.mouse_up {
			window.handle_mouse_up(e)
		}
		.mouse_move {
			// println('Mouse move')
			window.handle_mouse_move(e)
			// println(e)
		}
		.mouse_scroll {
			window.handle_mouse_scroll(e)
		}
		.key_down {
			window.handle_key_down(e)
		}
		.char {
			window.handle_char(e)
		}
		.quit_requested {
			println('Quit requested')
		}
		else {
			println('Unknown event')
		}
	}
}

fn (mut w Window) handle_mouse_down(e &gg.Event) {
	w.eventbus.publish('mouse_down', w, e)
	/*\
	for mut widget in w.children {

		if !widget.is_visible() && widget.point_inside(e.mouse_x, e.mouse_y) {

			if mut widget is Button {
				
				if widget.on_click != unsafe { nil } {
					widget.on_click(widget)
				}
			}
			
		}
	}*/
}

fn (mut w Window) handle_mouse_up(e &gg.Event) {
	w.eventbus.publish('mouse_up', w, e)
}

fn (mut w Window) handle_key_down(e &gg.Event) {
	w.eventbus.publish('key_down', w, e)
}

fn (mut w Window) handle_mouse_move(e &gg.Event) {
	w.eventbus.publish('mouse_move', w, e)
}

fn (mut w Window) handle_char(e &gg.Event) {
	w.eventbus.publish('char', w, e)
}

fn (mut w Window) handle_mouse_scroll(e &gg.Event) {
	w.eventbus.publish('mouse_scroll', w, e)
}
