local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("scss", {
	s({
		trig = "pixel",
		dscr = "fluid size in px",
		wordTrig = true,
		priority = 2000,
	}, {
		t("@include u.px("),
		i(1),
		t(", "),
		i(2),
		t(", "),
		i(3),
		t(", "),
		i(4),
		t(", "),
		i(5),
		t(");"),
	}),

	s({
		trig = "flex-center",
		dscr = "Display flex with center alignment",
		wordTrig = true,
		priority = 2000,
	}, {
		t("display: flex;"),
		t({ "", "  align-items: center;" }),
		t({ "", "  justify-content: center;" }),
		i(0),
	}),

	s({
		trig = "media",
		dscr = "Media query with u.mw mixin",
		wordTrig = true,
		priority = 2000,
	}, {
		t("@include u.mw("),
		i(1, "sm"),
		t({ ") {", "  " }),
		i(0),
		t({ "", "}" }),
	}),
})
