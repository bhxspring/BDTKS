function ind = partition( X_temp,w,b )

tmp = w*X_temp';
indUp = find(tmp>-b);
indDown = find(tmp<=-b);
ind{1,1} = indUp';
ind{2,1} = indDown';
if isempty(indUp)
    indUp = find(tmp==-b);
    indDown = find(tmp<-b);
    ind{1,1} = indUp';
    ind{2,1} = indDown';
    if isempty(indDown)
        ind(2)=[];
    end
end

end