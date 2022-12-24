local string, table, ipairs = string, table, ipairs

-- split_string splits a string on a separator and returns a table.
-- Empty values are returned as empty strings.
-- https://stackoverflow.com/a/7615129
function split_string(inputstr, sep)
	sep     = sep or '%s'
	local t = {}
	for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
		table.insert(t, field)
		if s == "" then
			return t
		end
	end
end

local split = split_string("a:awesome,b,h", ",")

for i, s in ipairs(split) do
	print(i .. " => " .. s)
end