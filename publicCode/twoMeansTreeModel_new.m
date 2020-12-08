function tree = twoMeansTreeModel_new(train_data,train_class,num_subspace,localErr )

[numTrain,numDim] = size(train_data);
train_classValue = unique(train_class);
stack{1,1} = train_data;
stack{1,2} = train_class;
x = train_data;
cl = train_class;
tree.childNode = cell(1,1);
tree.parentNode = cell(1,1);
tree.splitNumber = cell(1,1);
tree.existNumChild(1) = 0;
tree.ind_subspace = cell(1,1);
numSplit = 1;
totalNumChild = 0;
percent = hist(cl,train_classValue)/length(cl);
numChild = 2;
while (1)    
    stack(1,:) = [];    %取stack中的第一个cell元素进行划分，并将此元素删除
    if num_subspace==numDim
        tree.ind_subspace = 'a';
        x_tmp = x;
    else
        ind_dim = sort(randperm(numDim,num_subspace));
        x_tmp = x(:,ind_dim);      
        tree.ind_subspace{numSplit} = ind_dim;
    end
    [Idx,C] = kmeans(full(x_tmp),2,'MaxIter',1000);     
    if numSplit>1
        inx = find(strcmp(tree.childNode,'0'));
        tree.childNode{inx(1)} = 'p';     %找到之前划分数据时需要继续划分的第一个子节点，并赋值为'p'        
        tree.splitNumber{inx(1)} = numSplit;
    end
    for i=1:numChild
        index = find(Idx==i);
        c = cl(index);
        numSamp = length(c);
        percentage = hist(c,train_classValue)/numSamp;  %划分后两个子节点中各个类占各自节点中样本总数的百分比
        tree.splitNumber{totalNumChild+i} = 'l';       
        [max_perc,max_ind] = max(percentage);
        l = localErr*numTrain/numSamp/numSamp;
        dif = percentage-percent*l;
        ind_abandon =[max_ind,find(percentage==0)];
        dif(ind_abandon) = [];
        if all(dif(:)<0)&&max_perc>percent(max_ind)
            tree.childNode{totalNumChild+i} = percentage;  %子节点不用继续划分，则将其赋值为百分比最高的类的类别号
            continue;
        else
            tree.childNode{totalNumChild+i} = '0';        %子节点需要继续划分，暂将其标记为'0'
            stack{end+1,1} = x(index,:);  %将该子节点对应的数据添加到stack中
            stack{end,2} = c;   %将该子节点的类别号添加到stack中
        end
    end
    tree.parentNode{numSplit} = C;
    tree.existNumChild(numSplit) = totalNumChild;
    if isempty(stack) 
        break;
    else
        x = stack{1,1};    %取train_data_stack中的第一个cell元素进行下一次划分
        cl = stack{1,2};
        numSplit = numSplit+1;
        totalNumChild = totalNumChild+numChild;
    end    
end
dbstop if error
end
