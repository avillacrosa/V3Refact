function CreateVtkVol(Geo, Set)
%% ------- Initiate ---------------------------------------------------
str0=Set.OutputFolder;                          % First Name of the file 
fileExtension='.vtk';                            % extension

newSubFolder = fullfile(pwd, str0, 'Cells');
if ~exist(newSubFolder, 'dir')
    mkdir(newSubFolder);
end

% for c = 1:length(Geo.Cells)
for c = 1

	Y      = Geo.Cells(c).Y;
    nVert=size(Y,1);
    nFaces=length(Geo.Cells(c).Faces);

    %% Init file
	nameout=fullfile(newSubFolder, ['Cell_', num2str(c, '%04d'), fileExtension]);
	
    file=fopen(nameout,'w');
    fprintf(file,'%s\n','# vtk DataFile Version 3.98');
    fprintf(file,'%s\n','Delaunay_vtk');
    fprintf(file,'%s\n','ASCII');
    fprintf(file,'%s\n','DATASET UNSTRUCTURED_GRID');

    %% Basic cell structure
    nodes=nVert+nFaces;
    fprintf(file,'%s %d %s\n','POINTS',nodes,'float');
    % Vertices
    for numVertex=1:nVert
        fprintf(file,' %f %f %f\n',Y(numVertex,1),Y(numVertex,2),Y(numVertex,3));
    end
    % FaceCentres
    for numFace=1:nFaces
        fprintf(file,' %f %f %f\n',Geo.Cells(c).Faces(numFace).Centre);
    end
    
    %% Add each triangle that will form the cell
	totTris = 0;
	for f = 1:nFaces
		ntris = length(Geo.Cells(c).Faces(f).Tris);
		for t = 1:ntris
			totTris = totTris + 1;
		end
	end
		
    nn=0;
    fprintf(file,'%s %d %d\n','CELLS',totTris,4*totTris);
	for numFace=1:nFaces
		nTris = size(Geo.Cells(c).Faces(numFace).Tris,1);
		for numTri=1:nTris
			nY=Geo.Cells(c).Faces(numFace).Tris(numTri,:);
			if nY(3)<0
				nY(3)=abs(nY(3));
			else 
				nY(3)=nY(3)+nVert;
			end 
			fprintf(file,'%d %d %d %d\n',3,(nY(1)-1)...
                      					,(nY(2)-1)...
                      					,(nY(3)-1));
                      					nn=nn+1;
		end 
	end
    
    fprintf(file,'%s %d\n','CELL_TYPES',totTris);
    for numTries=1:totTris
        fprintf(file,'%d\n',5);
    end


%     %% ADD RELATIVE VOLUME CHANGE
%     fprintf(file,'%s %d \n','CELL_DATA',nTries);
%     fprintf(file,'%s \n','SCALARS RelVolChange double');
%     fprintf(file,'%s \n','LOOKUP_TABLE default');
%     ntri=ones(size(Cell.Tris{c},1),1);
%     fprintf(file,'%f\n', (Cell.Vol(c)-Cell.Vol0(c))/Cell.Vol0(c)*ntri);
% 
%     %% ADD RELATIVE Area CHANGE
%     %fprintf(file,'%s %d \n','CELL_DATA',nTries);
%     fprintf(file,'%s \n','SCALARS RelAreaChange double');
%     fprintf(file,'%s \n','LOOKUP_TABLE default');
%     ntri=ones(size(Cell.Tris{c},1),1);
%     fprintf(file,'%f\n', (Cell.SArea(c)-Cell.SArea0(c))/Cell.SArea0(c)*ntri);
% 
% 
%     %% ADD RELATIVE Tri Area CHANGE
%     %fprintf(file,'%s %d \n','CELL_DATA',nTries);
%     fprintf(file,'%s \n','SCALARS TriAreaChange double');
%     fprintf(file,'%s \n','LOOKUP_TABLE default');
%     for f=1:Cell.Faces{c}.nFaces
%         if Cell.Faces{c}.FaceCentresID(f) > 0
%             fprintf(file,'%3.35f\n', Cell.AllFaces.EnergyTri{Cell.Faces{c}.FaceCentresID(f)});
%         else
%             fprintf(file,'0\n');
%         end
%     end
    fclose(file);
end