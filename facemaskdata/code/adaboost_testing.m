%% adaboost one classifier eval

accuracy_all = zeros(strong_class_size_max,1);
eval_positive = zeros(test_faces_size,strong_class_size_max);
eval_negative = zeros(test_nonfaces_size,strong_class_size_max);
for acc_test = 1:strong_class_size_max

    for i =1: test_faces_size
        response=0;
        for j = 1:acc_test
            boosted =boosted_classifier(j,:);
            classifier_index = boosted(1);
            classifier_alpha = boosted(2);
            classifier_threshold = boosted(3);
            classifier = weak_classifiers{classifier_index};
            response1 = eval_weak_classifier(classifier, test_faces_integral(:,:,i));
            if (response1 > classifier_threshold)
                response2 = 1;
            else
                response2 = -1;
            end
            response = response + classifier_alpha * response2;
        end
        
        eval_positive(i, acc_test) = response;
    end
    
    for i =1: test_nonfaces_size
        response=0;
        for j = 1:acc_test
            boosted =boosted_classifier(j,:);
            classifier_index = boosted(1);
            classifier_alpha = boosted(2);
            classifier_threshold = boosted(3);
            classifier = weak_classifiers{classifier_index};
            response1 = eval_weak_classifier(classifier, test_nonfaces_integral(:,:,i));
            if (response1 > classifier_threshold)
                response2 = 1;
            else
                response2 = -1;
            end
            response = response + classifier_alpha * response2;
        end
        
        eval_negative(i, acc_test) = response;
    end
    
    eval_total = test_faces_size  + test_nonfaces_size;
    eval_all = [ eval_positive(eval_positive(:,acc_test) >0, acc_test); eval_negative(eval_negative(:,acc_test) < 0, acc_test)  ];
    accuracy = size(eval_all,1)/eval_total;
    fprintf('classifiers:%d accuracy: %.3f \n',acc_test,accuracy);
    accuracy_all(acc_test) = accuracy;
end

%%

figure(3); plot(accuracy_all);
TP = zeros(1,strong_class_size_max);
TN = zeros(1,strong_class_size_max);
FP = zeros(1,strong_class_size_max);
FN = zeros(1,strong_class_size_max);

for acc_test = 1:strong_class_size_max
    test_labels = categorical([ones(1,test_faces_size) zeros(1, test_nonfaces_size)]);
    test_pred = zeros(1,test_faces_size + test_nonfaces_size) -1;
    test_pred( find(eval_positive(:, acc_test) > 0) ) = 1;
    test_pred( find(eval_positive(:, acc_test) <0) ) = 0;
    test_pred( find(eval_negative(:, acc_test) < 0) + test_faces_size) = 0;
    test_pred( find(eval_negative(:, acc_test) > 0) + test_faces_size) = 1;
    %figure(2); plotconfusion(test_labels, categorical(test_pred));
    C = confusionmat(test_labels, categorical(test_pred));
    TP(acc_test) = C(2,2);
    TN(acc_test) = C(1,1);
    FP(acc_test) = C(1,2);
    FN(acc_test) = C(2,1);
end

figure(2);
t = tiledlayout(2,2,'TileSpacing','normal', 'Padding','normal');
p1 = plot(TP, 'g--');
title(t,'Boosted Classifiers')
xlabel(t,'\newline' ,'fontsize',15,'VerticalAlignment','top','HorizontalAlignment','center'); 
ylabel(t,'%','fontsize',15)
hold on;
p2 = plot(TN, 'b--');
p3 = plot(FP, 'r-');
p4 = plot(FN, 'k-');
set(gca, 'XLim', [1 50]);
set(gca, 'YLim', [-10 800]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
[y x] = max(TP);
hold on; % hold the plot for other curves
plot(x,y,'p','MarkerSize',10);
[y x] = max(TN);
hold on; % hold the plot for other curves
plot(x,y,'o','MarkerSize',10);

[y x] = min(FP);
hold on; % hold the plot for other curves
plot(x,y,'x','MarkerSize',10);
[y x] = min(FN);
hold on; % hold the plot for other curves
plot(x,y,'x','MarkerSize',10);

%for t = 1:numel(TP)
%  text(t, TP(t),[num2str(TP(t))])
%end
legend([p1; p2; p3; p4],'True positives', 'True Negatives', 'False positives','False Negatives', 'Location','southwest');

%% adaboost cascade
%classifier_size = [1, 5, 10, 19]; % based on above plot
%classifier_size = [1, 5, 10, 20]; % based on above plot
%classifier_size = [1, 5, 10, 50]; % based on above plot

%boosted_classifiers = cell(1, size(classifier_size,2));
%boosted_classifier = AdaBoost(responses, labels, max(classifier_size));
%% extract cascade - no threshold
%classifier_size = [1, 5, 10, 19];
%boosted_classifiers = struct('classifiers',[], 'threshold',{});
%counter=1;
%for i = classifier_size
%    boosted_classifiers(counter).classifiers = boosted_classifier(1:i,:);
%    boosted_classifiers(counter).threshold = 0;
%    counter = counter+1;
%end


%% eval cascade new thresholds on test data

accuracy_all_t = zeros(size(classifier_size,2),1);

%boosted =boosted_classifiers(j);
[eval_positive_t, eval_positive_thresholded] = evaluate_cascade(test_faces_integral, boosted_classifiers, weak_classifiers, cascade_thresholds(:,3));
[eval_negative_t, eval_negative_thresholded] = evaluate_cascade(test_nonfaces_integral, boosted_classifiers, weak_classifiers, cascade_thresholds(:,3));

for acc_test = 1:size(classifier_size,2)
    eval_total_t = test_faces_size  + test_nonfaces_size;
    eval_all_t = [ eval_positive_t(eval_positive_t(:,acc_test) >0, acc_test); eval_negative_t(eval_negative_t(:,acc_test) < 0, acc_test)  ];
    accuracy = size(eval_all_t,1)/eval_total_t;
    fprintf('classifiers:%d accuracy: %.3f \n',acc_test,accuracy);
    accuracy_all_t(acc_test) = accuracy;
end


%% evaluate boosted classifier 1
test = (imread('data/training_test_data/test_face_photos/obama8.jpg'));

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifier, weak_classifiers, [100, 100], 1); toc;
%figure(1); imshow(test, []);
figure(2); imshow(result, []);

positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');


tic; [result, boxes1] = boosted_detector_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 1); toc;
figure(3); imshow(result, []);

tic; [result, boxes2, scores] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  1, 1); toc;
figure(4); imshow(result, []);



%% evaluate boosted classifier 2
test = (imread('data/training_test_data/test_face_photos/IMG_3793.JPG'));
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 4); toc;
figure(5); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  4, 1); toc;
figure(6); imshow(result, []);

%% evaluate boosted classifier 3
test = (imread('data/training_test_data/test_face_photos/IMG_3840.JPG'));

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 4); toc;
figure(7); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  4,1); toc;
figure(8); imshow(result, []);


%% evaluate boosted classifier 7

test = imread('data/eval_cnn_photos/photos/test5.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:2, boosted_classifiers, weak_classifiers, [100, 100], 6); toc;
figure(9); imshow(result, []);

tic; [result, boxes1] = boosted_detector_skin_demo(test, 1:0.5:2, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  6, 1); toc;

figure(10); imshow(result, []);

%% evaluate boosted classifier 8 - skin

test = imread('data/eval_cnn_photos/photos/test1.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.4:3, boosted_classifiers, weak_classifiers, [100, 100], 4); toc;
figure(11); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.4:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  4, 1); toc;

figure(12); imshow(result, []);

%%

test = imread('photos/test4.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.4:3, boosted_classifiers, weak_classifiers, [100, 100], 2); toc;
figure(13); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.4:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  2, 1); toc;

figure(14); imshow(result, []);

%% evaluate boosted classifier 9 - skin

test = imread('data/eval_cnn_photos/photos/test6.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

skin = detect_skin(test, positives, negatives);
tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 3); toc;
figure(15); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  3, 1); toc;

figure(16); imshow(result, []);