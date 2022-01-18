function CellStr = BuildStructArray(n, fields)
	
	CellStr = struct();
	for f = 1:length(fields)
		CellStr.(fields(f)) = {};
	end
	for c = 2:n
		temp_str = struct();
		for f = 1:length(fields)
			temp_str.(fields(f)) = {};
		end
		CellStr(c) = temp_str;
	end
end