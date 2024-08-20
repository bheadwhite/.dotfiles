local M = {}

-- Function to deduplicate a list
function M.deduplicate_list(list)
	local seen = {}
	local deduped = {}

	for _, item in ipairs(list) do
		if not seen[item] then
			table.insert(deduped, item)
			seen[item] = true
		end
	end

	return deduped
end

-- Function to sort a list of symbols by name property
function M.sort_by_name(symbols)
	table.sort(symbols, function(a, b)
		return a.name < b.name
	end)
end

-- Function to check if a string matches any keyword in a list
function M.matches_any(string, keywords)
	for _, keyword in ipairs(keywords) do
		if string:find("^" .. keyword) then
			return true
		end
	end
	return false
end

return M
