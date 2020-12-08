function b = bias_median(w,X)

tmp = w*X';
[temp,~] = sort(tmp);
id = find(temp == median(temp));
[~,ind_unique,~] = unique(tmp','rows','stable');
if isempty(id) || numel(ind_unique)==1
    b = -median(tmp);
else
    if id(1) == 1
        b = -mean([temp(id(end)),temp(id(end)+1)]);
    else
        b = -mean([temp(id(1)-1),temp(id(1))]);
    end
end

end