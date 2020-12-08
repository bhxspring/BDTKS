close all
clear
clc
addpath('.\publicCode');
% profile on
rng(12);
strings = {'satimage.scale'};
path = 'data\';
d = 'results_BDTKSv1';
times = 5;
tree = cell(1,times);
accuracy = zeros(times,1);
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
    for localErr=10.^(-6:3)
        sum_accuracy = 0;
        for rep = 1:times
            tr = twoMeansTreeModel_new(train_data(train,:),train_class(train),numDim,localErr);
            [~,label] = kmeansTreePrediction( train_data(val,:),tr,classValue);
            a = label==train_class(val);
            accuracy = length(find(a==1))/length(a);
            sum_accuracy = sum_accuracy+accuracy;
        end
        acc = sum_accuracy/times;
        if acc>best_acc
            best_acc = acc;
            best_localErr =  localErr;
        end
    end
    tr = cell(times,1);
    for rep = 1:times
        tr{rep} = twoMeansTreeModel_new(train_data,train_class,numDim,best_localErr);
    end    
    t_temp = clock;
    label = zeros(size(test_data,1),times);
    for rep = 1:times
        [~,label(:,rep)] = kmeansTreePrediction( test_data,tr{rep},classValue);
    end
    t_end = clock;
    t_train = etime(t_temp,t_start);
    t_test = etime(t_end,t_temp)/times;
    numSplit = zeros(times,1);
    for i=1:times
        numSplit(i) = length(tr{i}.parentNode);
    end
    %%%%%%%%%%%%%% Estimation %%%%%%%%%%%%%%%%%
    t_perSamp = t_test/size(test_data,1);
    accuracy = zeros(times,1);
    [precision,recall] = deal(zeros(numClass,times));
    for rep=1:times
        a = label(:,rep)==test_class;
        accuracy(rep) = length(find(a==1))/length(a);
        for i=1:numClass
            ind_p = find(label(:,rep)==classValue(i));
            ind_o = find(test_class==classValue(i));
            Num_p = length(ind_p);
            Num_o = length(ind_o);
            ind = [ind_p;ind_o];
            num = length(ind)-length(unique(ind));
            if Num_p==0
                precision(i,rep) = 0;
            else
                precision(i,rep) = num/Num_p;
            end
            if Num_o==0
                recall(i,rep) = 0;
            else
                recall(i,rep) = num/Num_o;
            end
        end
    end
    %%%%%%%%%%%%%%% Save %%%%%%%%%%%%%%%%%%%
    if ~exist(d,'dir')
        mkdir(d);
    end
    save([d,'\',datasetName,'.mat'],'best_localErr','accuracy','t_train','t_test','numSplit','label','precision','recall','t_perSamp');
    
end
dbstop if error
% profile viewer


