require("luasnip.session.snippet_collection").clear_snippets("php")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("php", {
	s("fn", fmt("function {} ({}) {{\n\t{}\n}}", { i(1), i(2), i(3) })),
	s("if", fmt("if ({}) {{\n\t{}\n}}", { i(1), i(2) })),
	s("elif", fmt("elseif ({}) {{\n\t{}\n}}", { i(1), i(2) })),
	s("el", fmt("else {{\n\t{}\n}}", { i(1) })),
	s("each", fmt("foreach ({}) {{\n\t{}\n}}", { i(1), i(2) })),
	s("for", fmt("for ({}) {{\n\t{}\n}}", { i(1), i(2) })),
	s("comp", fmt("<?= component('{}', [{}]) ?>", { i(1), i(2) })),
	s("p", fmt("<?php {} ;?>", { i(1) })),
	s("pif", fmt("<?php if ({}) :?>\n\t{}\n<?php endif ;?>", { i(1), i(2) })),
	s("pel", fmt("<?php else :?>\n\t{}", { i(1) })),
	s("pelif", fmt("<?php elseif ({}) :?>\n\t{}", { i(1), i(2) })),
	s("peach", fmt("<?php foreach ({}) :?>\n\t{}\n<?php endforeach ;?>", { i(1), i(2) })),
})
