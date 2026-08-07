require("luasnip.session.snippet_collection").clear_snippets("typescriptreact")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local rep = require("luasnip.extras").rep
local events = require("luasnip.util.events")

local insert_import = require("user.utils.str.utils").insert_import
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("typescriptreact", {
	s(
		"ustr",
		fmt("const [{}, set{}] = useState{}({});", {
			i(1),
			d(2, function(args)
				local cap = (args[1][1] or ""):gsub("^%l", string.upper)
				return sn(nil, { t(cap) })
			end, { 1 }),
			i(4),
			i(3),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useState } from 'react';")
					end,
				},
			},
		}
	),
	s(
		"ustp",
		fmt("const [{}, set{}] = useState{}({});", {
			i(1),
			d(2, function(args)
				local cap = (args[1][1] or ""):gsub("^%l", string.upper)
				return sn(nil, { t(cap) })
			end, { 1 }),
			i(4),
			i(3),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useState } from 'preact/hooks';")
					end,
				},
			},
		}
	),
	s(
		"uefr",
		fmt("useEffect(() => {{\n\t{}\n\n\treturn () => {{\n\t\t{}\n\t}};\n}}, [{}]);{}", {
			i(1),
			i(2),
			i(3),
			i(0),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useEffect } from 'react';")
					end,
				},
			},
		}
	),
	s(
		"uefp",
		fmt("useEffect(() => {{\n\t{}\n\n\treturn () => {{\n\t\t{}\n\t}};\n}}, [{}]);{}", {
			i(1),
			i(2),
			i(3),
			i(0),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useEffect } from 'preact/hooks';")
					end,
				},
			},
		}
	),
	s(
		"urfr",
		fmt("const {} = useRef({});", {
			i(1),
			i(2),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useRef } from 'react';")
					end,
				},
			},
		}
	),
	s(
		"urfp",
		fmt("const {} = useRef({});", {
			i(1),
			i(2),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useRef } from 'preact/hooks';")
					end,
				},
			},
		}
	),
	s(
		"usgn",
		fmt("const {} = useSignal({});", {
			i(1),
			i(2),
		}),
		{
			callbacks = {
				[1] = {
					[events.enter] = function()
						insert_import("import { useSignal } from '@preact/signals';")
					end,
				},
			},
		}
	),
	s(
		"cmpr",
		fmt(
			"import type {{ FC }} from 'react';\n\nconst {}: FC<{}> = ({{ {} }}) => {{\n\treturn ({});\n}};\n\nexport default {};",
			{
				d(1, function()
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
					return sn(nil, { t(filename) })
				end, { 1 }),
				i(2, "NodeProps"),
				i(3, "className"),
				i(4, "<></>"),
				rep(1),
			}
		)
	),
	s(
		"cmpp",
		fmt(
			"import type {{ ComponentChildren }} from 'preact';\nimport type {{ FC }} from 'preact/compat';\n\nconst {}: FC<{}> = ({{ {} }}) => {{\n\treturn ({});\n}};\n\nexport default {};",
			{
				d(1, function()
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
					return sn(nil, { t(filename) })
				end, { 1 }),
				i(2, "{ className?: string, children: ComponentChildren }"),
				i(3, "className, children"),
				i(4, "<></>"),
				rep(1),
			}
		)
	),
	s("cl", fmt("class='{}'", { i(1) })),
	s("edfn", fmt("export default function {} ({}) {{\n\t{}\n}}", { i(1, "functionName"), i(2, ""), i(0) })),
	s("fn", fmt("function {} ({}) {{\n\t{}\n}}", { i(1, "functionName"), i(2, ""), i(0) })),
	s("afn", fmt("const {} = ({}) => {{\n\t{}\n}}", { i(1, "functionName"), i(2, ""), i(0) })),
	s("aev", fmt("addEventListener('{}', ({}) => {{\n\t{}\n}})", { i(1, "click"), i(2, "e"), i(0) })),
	s("log", fmt("console.log({})", { i(1) })),
})
