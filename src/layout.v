module cosmosui

import gg
import gx

pub enum Overflow {
	auto
	clip
	scroll
}

pub interface Layout {
	Widget
mut:
	children              []Widget
	overflow              Overflow
	scrollview            &Scrollview
	total_children_width  int
	total_children_height int
}
