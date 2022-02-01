function CreateVtkCell(Geo, Set, Step)
	%% ============================= INITIATE =============================
	str0=Set.OutputFolder;                          % First Name of the file 
	fileExtension='.vtk';                            % extension
	
	newSubFolder = fullfile(pwd, str0, 'Cells');
	if ~exist(newSubFolder, 'dir')
    	mkdir(newSubFolder);
	end

	for c = 1:Geo.nCells
		Ys = Geo.Cells(c).Y;
		nameout=fullfile(newSubFolder, ['Cell_', num2str(c, '%04d'), '_t', num2str(Step, '%04d'), fileExtension]);
		fout=fopen(nameout,'w');

		header = "# vtk DataFile Version 3.98\n";
		header = header + "Delaunay_vtk\n";
		header = header + "ASCII\n";
		header = header + "DATASET UNSTRUCTURED_GRID\n";

		points = ""; cells = ""; cells_type = "";
		for yi = 1:length(Ys)
			points = points + sprintf(" %.8f %.8f %.8f\n",...
								   Ys(yi,1),Ys(yi,2),Ys(yi,3));

		end

		nTriFaces = 0; totCells = 0;

		for f = 1:length(Geo.Cells(c).Faces)
			Face = Geo.Cells(c).Faces(f);
			if length(Face.Tris)==3
				n3 = Face.Tris(2,2)-1;
				nTriFaces = nTriFaces + 1;
			else
				points = points + sprintf(" %.8f %.8f %.8f\n",...
							Face.Centre(1),Face.Centre(2),Face.Centre(3));
				n3 = f+length(Ys)-1-nTriFaces;
			end
		    for t = 1:length(Face.Tris)
			    cells    = cells + sprintf("3 %d %d %d\n",...
							    Face.Tris(t,1)-1, Face.Tris(t,2)-1, n3);
				totCells = totCells + 1;
		    end
		end

		for numTries=1:totCells
        	cells_type = cells_type + sprintf('%d\n',5);
		end

		points = sprintf("POINTS %d float\n", ...
				length(Ys)+length(Geo.Cells(c).Faces)-nTriFaces) + points;
		cells  = sprintf("CELLS %d %d\n",totCells,4*totCells) + cells;
		cells_type = sprintf("CELL_TYPES %d \n", totCells) + cells_type;

		fprintf(fout, header + points + cells + cells_type);
		fclose(fout);
	end
end