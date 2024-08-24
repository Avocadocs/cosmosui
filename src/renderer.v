module cosmosui

import gx
import gg

pub fn (mut w Window) draw(mut ctx gg.Context) {
	ctx.begin()

	for mut widget in w.children {
		widget.draw(mut ctx)
	}

	ctx.end()
}
