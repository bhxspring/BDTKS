function tree = acceleratedTwoMeansTreeModel_pcaInitialized_new(train_data,train_class,num_subspace,localErr )

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
    stack(1,:) = [];    %ȡstack�еĵ�һ��cellԪ�ؽ��л��֣�������Ԫ��ɾ��
    if num_subspace==numDim
        tree.ind_subspace = 'a';
        x_tmp = x;
        w = pca_w(x_tmp);
        b = bias_median(w,x_tmp);
        index = partition(x_tmp,w,b);
    else
        ind_dim = sort(randperm(numDim,num_subspace));
        x_tmp = x(:,ind_dim);
        w = pca_w(x_tmp);
        b = bias_median(w,x_tmp);
        index = partition(x_tmp,w,b);
        while length(index)==1
            ind_dim = sort(randomSubspace(x,num_subspace));
            x_tmp = x(:,ind_dim);
            w = pca_w(x_tmp);
            b = bias_median(w,x_tmp);
            index = partition(x_tmp,w,b);
        end        
        tree.ind_subspace{numSplit} = ind_dim;
    end
    C0 = [mean(x_tmp(index{1,1},:),1);mean(x_tmp(index{2,1},:),1)];
    [Idx,C] = kmeans(full(x_tmp),numChild,'MaxIter',1000,'start',full(C0)); 
    w = (C(1,:)-C(2,:));
    b = -w*((sum(C))/2)';
    if C(1,:)*w'+b<0
        Idx=Idx-1;
        Idx(Idx==0) = 2;
    end
    if numSplit>1
        inx = find(strcmp(tree.childNode,'0'));
        tree.childNode{inx(1)} = 'p';     %�ҵ�֮ǰ��������ʱ��Ҫ�������ֵĵ�һ���ӽڵ㣬����ֵΪ'p'        
        tree.splitNumber{inx(1)} = numSplit;
    end
    for i=1:numChild
        index = find(Idx==i);
        c = cl(index);
        numSamp = length(c);
        percentage = hist(c,train_classValue)/numSamp;  %���ֺ������ӽڵ��и�����ռ���Խڵ������������İٷֱ�
        tree.splitNumber{totalNumChild+i} = 'l';       
        [max_perc,max_ind] = max(percentage);
        l = localErr*numTrain/numSamp/numSamp;
        dif = percentage-percent*l;
        ind_abandon =[max_ind,find(percentage==0)];
        dif(ind_abandon) = [];
        if all(dif(:)<0)&&max_perc>percent(max_ind)
            tree.childNode{totalNumChild+i} = percentage;  %�ӽڵ㲻�ü������֣����丳ֵΪ�ٷֱ���ߵ��������
            continue;
        else
            tree.childNode{totalNumChild+i} = '0';        %�ӽڵ���Ҫ�������֣��ݽ�����Ϊ'0'
            stack{end+1,1} = x(index,:);  %�����ӽڵ��Ӧ��������ӵ�stack��
            stack{end,2} = c;   %�����ӽڵ��������ӵ�stack��
        end
    end
    tree.parentNode{numSplit} = [w,b];
    tree.existNumChild(numSplit) = totalNumChild;
    if isempty(stack) 
        break;
    else
        x = stack{1,1};    %ȡtrain_data_stack�еĵ�һ��cellԪ�ؽ�����һ�λ���
        cl = stack{1,2};
        numSplit = numSplit+1;
        totalNumChild = totalNumChild+numChild;
    end    
end
dbstop if error
end