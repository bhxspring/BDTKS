function [prob,label] = kmeansTreePrediction( test_data,tree,classValue )
% profile on
[m,~] = size(test_data);
numClass = length(classValue);
prob = zeros(m,numClass);
parfor n=1:m
    x = test_data(n,:);
    nodeNumber = 1;
    while (1)
        if ~ischar(tree.ind_subspace)
            x_tmp = x(:,tree.ind_subspace{nodeNumber});
        else
            x_tmp = x;
        end
        C = tree.parentNode{nodeNumber};
        temp = C-repmat(x_tmp,size(C,1),1);
        dist = sum(temp.*temp,2);
        [~,minIdx] = min(dist);
        if length(dist)==2&&dist(1)==dist(2)
            minIdx = 2;
        end
        if ~ischar(tree.childNode{tree.existNumChild(nodeNumber)+minIdx})
            prob(n,:) = tree.childNode{tree.existNumChild(nodeNumber)+minIdx};
            break;
        else
            nodeNumber = tree.splitNumber{tree.existNumChild(nodeNumber)+minIdx};
        end
    end
end
[~,ind] = max(prob,[],2);
label = classValue(ind);
dbstop if error
% profile viewer
end

