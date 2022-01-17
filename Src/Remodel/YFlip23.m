function [Ynew, Tnew] = YFlip23(Ys, Ts, edgeToChange, Geo)
	n3=Ts(edgeToChange(1),  ismember(Ts(edgeToChange(1),:), Ts(edgeToChange(2),:)));
	n1=Ts(edgeToChange(1), ~ismember(Ts(edgeToChange(1),:),n3));
	n2=Ts(edgeToChange(2), ~ismember(Ts(edgeToChange(2),:),n3));
	num=[1 2 3 4];
	num=num(Ts(edgeToChange(1),:)==n1);
	if num == 2 || num == 4
		Tnew=[n3([1 2]) n2 n1;
			  n3([2 3]) n2 n1;
			  n3([3 1]) n2 n1];
	else
		Tnew=[n3([1 2]) n1 n2;
			  n3([2 3]) n1 n2;
			  n3([3 1]) n1 n2];       
	end
	
	ghostNodes = ismember(Tnew,Geo.XgID);
	ghostNodes = all(ghostNodes,2);
	if any(ghostNodes)
		fprintf('=>> Flips 2-2 are not allowed for now\n');
		return
	end
	
	Ynew=DoFlip23(Ys(edgeToChange,:),Geo,n3);
	Ynew(ghostNodes,:)=[];
end