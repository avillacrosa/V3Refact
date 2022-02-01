function ftype = BuildInterfaceType(ij, XgID)
	% TODO FIXME, this is a simplification atm, should be more detailed 
	% on the long term, but it is also similar to previous version
	if any(ismember(ij, XgID))
		ftype = 0;
	else
		ftype = 1;
	end
end