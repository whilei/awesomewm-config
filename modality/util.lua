local x             = {}

x.debug_print_paths = function(prefix, v)
	if v == nil then
		print(prefix, "<nil>")
	end
	for k, v in pairs(v) do
		if type(v) == "table" then
			print(prefix, k, "")
			x.debug_print_paths(prefix .. "\t", v)
			print(prefix)
		else
			print(prefix, k, v)
		end
	end
end

return x