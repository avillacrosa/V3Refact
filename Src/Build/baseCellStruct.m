function CellStr = baseCellStruct(X)
	fields = ["X", "T", "Y", "Faces"];
	
	CellStr = struct();
	for f = 1:length(fields)
		CellStr.(fields(f)) = {};
	end
	for c = 2:length(X)
		temp_str = struct();
		for f = 1:length(fields)
			temp_str.(fields(f)) = {};
		end
		CellStr(c) = temp_str;
	end
end