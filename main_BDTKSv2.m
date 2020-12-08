close all
clear
clc
addpath('.\publicCode');
% profile on
strings = {'satimage.scale'};
path = 'data\';
d = 'results_BDTKSv2';
for s=1:length(strings)

    datasetName = strings{1,s};
    load([path,datasetName,'.mat']);
    if min(train_class) <= 0
        train_class = train_class+abs(min(train_class))+1;
        test_class = test_class+abs(min(test_class))+1;
    end
    numDim = size(train_data,2);
    classValue = unique(train_class); 
    numClass = length(classValue);
    
    t_start = clock;
    best_acc = 0;
    for localErr = 10.^(-6:3)
        tr = twoMeansTreeModel_pcaInitialized_new(train_data(train,:),train_class(train),numDim,localErr);
        [~,label] = kmeansTreePrediction( train_data(val,:),tr,classValue );
        a = label==train_class(val);
        acc = length(find(a==1))/length(a);
        if acc>best_acc
            best_acc = acc;
            best_localErr =  localErr;
        end
    end
    tr = twoMeansTreeModel_pcaInitialized_new(train_data,train_class,numDim,best_localErr);
    t_temp = clock;
    [~,label] = kmeansTreePrediction(test_data,tr,classValue );
    t_end = clock;
    t_train = etime(t_temp,t_start);
    t_test = etime(t_end,t_temp);
    numSplit = length(tr.parentNode);
    %%%%%%%%%%%%%% Estimation %%%%%%%%%%%%%%%%%
    n_perSecond = size(test_data,1)/t_test;
    t_perSamp = 1/n_perSecond;
    a = label==test_class;
    accuracy = length(find(a==1))/length(a);
    [precision,recall] = deal(zeros(numClass,1));
    for i=1:numClass
        ind_p = find(label==classValue(i));
        ind_o = find(test_class==classValue(i));
        Num_p = length(ind_p);
        Num_o = length(ind_o);
        ind = [ind_p;ind_o];
        num = length(ind)-length(unique(ind));
        if Num_p==0
            precision(i) = 0;
        else
            precision(i) = num/Num_p;
        end
        if Num_o==0
            recall(i) = 0;
        else
            recall(i) = num/Num_o;
        end
    end
    %%%%%%%%%%%%% Save %%%%%%%%%%%%%%%%%%%
    if ~exist(d,'dir')
        mkdir(d);
    end
    save([d,'\',datasetName,'.mat'],'best_localErr','accuracy','t_train','t_test','numSplit','label','precision','recall','t_perSamp');

end
dbstop if error
% profile viewer


