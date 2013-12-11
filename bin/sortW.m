function [sortedW] = sortW(W)
% NMF computes an unsorted W matrix. This method sorts the W matrix by the maximum frequency in each column of W. It's not perfect, but it's better than sorting by hand
% Find the maximum frequency in each column of W
% Order the columns by those max frequencies

[val, ind] = max(W);
[sorted, sort_ind] = sort(ind);
sortedW = W(:,sort_ind);

end

