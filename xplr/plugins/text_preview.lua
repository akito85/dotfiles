local function stat(node)
	return node.mime_essence
end

local function read(path, height)
	local p = io.open(path)

	if p == nil then
		return nil
	end

	local i = 0
	local res = ""
	for line in p:lines() do
		if line:match("[^ -~\n\t]") then
			p:close()
			return
		end

		res = res .. line .. "\n"
		if i == height then
			break
		end
		i = i + 1
	end
	p:close()

	return res
end

xplr.config.layouts.builtin.default = {
	Horizontal = {
		config = {
			constraints = {
				{ Percentage = 60 },
				{ Percentage = 40 },
			},
		},
		splits = {
			"Table",
			{
				CustomContent = {
					title = "preview",
					body = { DynamicParagraph = { render = "custom.preview_pane.render" } },
				},
			},
		},
	},
}

xplr.fn.custom.preview_pane = {}
xplr.fn.custom.preview_pane.render = function(ctx)
	local n = ctx.app.focused_node

	if n and n.canonical then
		n = n.canonical
	end

	if n then
		if n.is_file then
			return read(n.absolute_path, ctx.layout_size.height)
		else
			return stat(n)
		end
	else
		return ""
	end
end
