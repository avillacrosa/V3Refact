function [g, K] = initializeKg(Geo, Set)
	dimg=(Geo.numY+Geo.numF)*3;

	g = zeros(dimg, 1);
	K = zeros(dimg, dimg);
end