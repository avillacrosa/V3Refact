a = [1 2
	 3 4
	 1 3
	 5 6
	 7 8];
b = [3 4];
any(sum(ismember(a,b), 2)==2)