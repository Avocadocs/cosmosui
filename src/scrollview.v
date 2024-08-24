module cosmosui

import gg
import gx
import math { clamp }

const scrollbar_size = 16
const scrollbar_track_color = gx.red
const scrollbar_thumb_color = gx.blue

pub enum ActiveThumb {
	x
	y
}

@[heap]
pub struct Scrollview {
pub mut:
	active_thumb      ActiveThumb
	layout            &Layout = unsafe { nil }
	scrollbar_size	int
	dragging          bool
	drag_start_offset f32
	scroll_x          int
	scroll_y          int
	thumb_width       int
	thumb_height      int
	scroll_factor     f32 = 20
	scrollbar_x       bool
	scrollbar_y       bool
	track_color       gx.Color
	thumb_color       gx.Color
}

pub struct ScrollviewParams {
	layout &Layout = unsafe { nil }
	scrollbar_size  int     = cosmosui.scrollbar_size
	track_color	 gx.Color = cosmosui.scrollbar_track_color
	thumb_color	 gx.Color = cosmosui.scrollbar_thumb_color
}

pub fn scrollview(c ScrollviewParams) &Scrollview {
	return &Scrollview{
		layout: c.layout
		scrollbar_size: c.scrollbar_size
		track_color: c.track_color
		thumb_color: c.thumb_color
	}
}

pub fn (mut s Scrollview) draw(ctx gg.Context) {
	mut layout := s.layout

	if s.scrollbar_x {
		s.thumb_width = int((f32(layout.width) / f32(layout.total_children_width)) * f32(layout.width))
		max_scroll_x := layout.total_children_width - layout.width

		ctx.draw_rect_filled(layout.x, layout.y + layout.height - s.scrollbar_size, layout.width,
			s.scrollbar_size, s.track_color)
		ctx.draw_rect_filled(layout.x +
			int(f32(s.scroll_x) * (f32(layout.width - s.thumb_width) / f32(max_scroll_x))),
			layout.y + layout.height - s.scrollbar_size, s.thumb_width, s.scrollbar_size, s.thumb_color)
	}

	if s.scrollbar_y {
		s.thumb_height = int((f32(layout.height) / f32(layout.total_children_height)) * f32(layout.height))
		max_scroll_y := layout.total_children_height - layout.height

		ctx.draw_rect_filled(layout.x + layout.width - s.scrollbar_size, layout.y, s.scrollbar_size, layout.height,
			s.track_color)
		ctx.draw_rect_filled(layout.x + layout.width - s.scrollbar_size, layout.y +
			int(f32(s.scroll_y) * (f32(layout.height - s.thumb_height) / f32(max_scroll_y))),
			s.scrollbar_size, s.thumb_height, s.thumb_color)
	}
}

fn (s Scrollview) point_inside_thumb(x f32, y f32, axis ActiveThumb) bool {
	mut layout := s.layout
	if axis == .x {
		return
			x >= layout.x + int(f32(s.scroll_x) * (f32(layout.width - s.thumb_width) / f32(layout.total_children_width)))
			&& x <= layout.x + int(f32(s.scroll_x) * (f32(layout.width - s.thumb_width) / f32(layout.total_children_width)) + s.thumb_width)
			&& y >= layout.y + layout.height - s.scrollbar_size && y <= layout.y + layout.height
	} else {
		return x >= layout.x + layout.width - s.scrollbar_size && x <= layout.x + layout.width
			&& y >= layout.y + int(f32(s.scroll_y) * (f32(layout.height - s.thumb_height) / f32(layout.total_children_height)))
			&& y <= layout.y + int(f32(s.scroll_y) * (f32(layout.height - s.thumb_height) / f32(layout.total_children_height)) + s.thumb_height)
	}
}

pub fn (mut s Scrollview) init(w &Window) {
	mut sub := w.eventbus.subscriber
	sub.subscribe_method('mouse_scroll', scroll, s)
	sub.subscribe_method('mouse_down', thumb_click, s)
	sub.subscribe_method('mouse_up', thumb_release, s)
	sub.subscribe_method('mouse_move', thumb_move, s)
}

pub fn thumb_click(mut s Scrollview, e &gg.Event, w &Window) {
	if s.point_inside_thumb(e.mouse_x, e.mouse_y, .y) {
		s.dragging = true
		s.active_thumb = .y
		s.drag_start_offset = e.mouse_y - (s.layout.y +int(f32(s.scroll_y) * (f32(s.layout.height - s.thumb_height) / f32(s.layout.total_children_height - s.layout.height))))
	} else if s.point_inside_thumb(e.mouse_x, e.mouse_y, .x) {
		s.dragging = true
		s.active_thumb = .x
		s.drag_start_offset = e.mouse_x - (s.layout.x +int(f32(s.scroll_x) * (f32(s.layout.width - s.thumb_width) / f32(s.layout.total_children_width - s.layout.width))))
	}
}

pub fn thumb_release(mut s Scrollview, e &gg.Event, w &Window) {
	s.dragging = false
}

pub fn thumb_move(mut s Scrollview, e &gg.Event, w &Window) {
	if s.dragging {
		match s.active_thumb {
			.x {
				max_scroll_x := s.layout.total_children_width - s.layout.width
				new_thumb_x := e.mouse_x - s.drag_start_offset
				s.scroll_x = int(f32(new_thumb_x) * (f32(max_scroll_x) / f32(s.layout.width - s.thumb_width)))
				s.scroll_x = int(clamp(s.scroll_x, 0, max_scroll_x))
			}
			.y {
				max_scroll_y := s.layout.total_children_height - s.layout.height
				new_thumb_y := e.mouse_y - s.drag_start_offset
				s.scroll_y = int(f32(new_thumb_y) * (f32(max_scroll_y) / f32(s.layout.height - s.thumb_height)))
				s.scroll_y = int(clamp(s.scroll_y, 0, max_scroll_y))
			}
		}
	}
}

fn scroll(mut s Scrollview, e &gg.Event, w &Window) {
	if !s.layout.point_inside(e.mouse_x, e.mouse_y) {
		return
	}
	if e.scroll_y > 0 {
		s.scroll_y = int(clamp(s.scroll_y - s.scroll_factor, 0, s.layout.total_children_height - s.layout.height))
	} else {
		s.scroll_y = int(clamp(s.scroll_y + s.scroll_factor, 0, s.layout.total_children_height - s.layout.height))
	}
}
