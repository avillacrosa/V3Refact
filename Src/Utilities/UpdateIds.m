function newgIds = UpdateIds(Geo_backup, Geo, newgIds)
	for c = 1:Geo.nCells
		oldLocalIds = find(Geo_backup.Cells(c).globalIds == newgIds);
		newLocalIds = find(Geo.Cells(c).Y == Geo_backup.Cells(c).Y(oldLocalIds,:));
		newgIds(newgIds==Geo_backup.Cells(c).globalIds) = Geo.Cells(c).globalIds(newLocalIds);
		for f = 1:length(Geo_backup.Cells(c).Faces)
			if ismember(Geo_backup.Cells(c).Faces(f).globalIds, newgIds)
				for f2 = 1:length(Geo.Cells(c).Faces)
					if Geo_backup.Cells(c).Faces(f).Cent
				end
			end
		end
	end
end