clc
b = [1 1 1
     2 2 2
     3 3 3
     4 4 4
     5 5 5
     6 6 6
     7 7 7];
for i = 1:21
    [c,r] = ind2sub(size(b'),i)
end

