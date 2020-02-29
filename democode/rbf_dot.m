function dpt = rbf_dot(data1, data2, deg)
%RBF_DOT Compute dot product table
%	rbf_dot(data1, data2, deg)
%	computes
%       exp(||x - y||^2/deg)
%	data entries in data1 and data2 per column, i.e. number of columns is number
% 	of samples

if nargin > 3 error('wrong number of arguments'); end


	[row1, col1] = size(data1);
	[row2, col2] = size(data2);
	dpt = zeros(col1, col2);
	i = 1; 
	% local variable for dpt
	for x1 = data1,
		j = 1;
		% local variable for inner loop

		for x2 = data2,
			dpt(i,j) = norm(x1 - x2);
            j = j + 1;
		end;
		i = i + 1;
	end;

dpt = exp(-(dpt.^2)/deg);