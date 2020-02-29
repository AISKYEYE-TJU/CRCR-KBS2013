function dpt = rbf_dot_self(data1, deg)
%RBF_DOT Compute dot product table
%	rbf_dot(data1, deg)
%	computes the dpt between data1 and data1
%       exp(||x - y||^2/deg)
%	each column of data1 is a data vector




if nargin > 2 error('wrong number of arguments'); end


	[row1, col1] = size(data1);
	dpt = zeros(col1, col1);
	i = 1; 
	% local variable for dpt
	for x1 = data1,
		j = i;
		% local variable for inner loop
		for x2 = data1(:,i:col1),
			dpt(i,j) = norm(x1 - x2);
            dpt(j,i) = dpt(i,j);
			j = j + 1;
		end;
		i = i + 1;
	end;

dpt = exp(-(dpt.^2)/deg);