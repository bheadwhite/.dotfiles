local M = {}

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

return M
