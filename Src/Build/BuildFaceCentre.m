function Centre = BuildFaceCentre(Ys)
	%BUILDFACECENTRE Build the centre of the face (interpolation)
	%   Detailed explanation goes here
	% TODO FIXME This function does much more in its original version. For
	% now, let's only calculate the interpolation.
    Centre=sum(Ys,1)/length(Ys);
end

