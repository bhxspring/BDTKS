function [prob,label] = multivariateBinaryTreePrediction( test_data,tree,classValue )

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
        wb = tree.parentNode{nodeNumber};
        if sum(wb(1:end-1).*x_tmp) > -wb(end)
            minIdx = 1;
        else
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
end

