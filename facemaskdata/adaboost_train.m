%% load train faces and calc integral

h=100;
w=100;
c=1;
training_faces_list = dir('data/training_test_data/training_faces');
training_faces_size = size(training_faces_list,1);
training_faces = zeros(h,w,3000);
training_faces_integral = zeros(h,w,3000);
count=1;
for i =1:training_faces_size
   
    if endsWith(training_faces_list(i).name, '.bmp', 'IgnoreCase',true)
        fprintf('face: %s \n',strcat(training_faces_list(i).folder,'/',training_faces_list(i).name));
        training_faces(:,:,count) = imread(strcat(training_faces_list(i).folder,'/',training_faces_list(i).name));
        training_faces_integral(:,:,count) = integral_image(training_faces(:,:,count) );
        count = count +1;
    end
    
end

training_faces_size = count -1;

%% load train nonfaces and calc integral

h=100;
w=100;
c=1;
training_nonfaces_list = dir('data/training_test_data/training_nonfaces');
training_nonfaces_size = size(training_nonfaces_list,1);
training_nonfaces = zeros(h,w,120);
training_nonfaces_integral = zeros(h,w,120);
count=1;
total_non_faces=5000;
patch = cell(total_non_faces);
for i =1:training_nonfaces_size
   
    if endsWith(training_nonfaces_list(i).name, '.jpg', 'IgnoreCase',true)
        
            fprintf('nonface: %s \n',strcat(training_nonfaces_list(i).folder,'/',training_nonfaces_list(i).name));
            image = rgb2gray(imread(strcat(training_nonfaces_list(i).folder,'/',training_nonfaces_list(i).name)));
            [r,c] = size(image);
            if(r <= 100 || c <= 100)
                break;
            end
            
        for j = 1:6
            rnd_x = randperm(r-h,6);
            rnd_y = randperm(c-w,6);
            patch{j} = image((rnd_x(j):(rnd_x(j)+h-1)),(rnd_y(j):(rnd_y(j)+w-1)));
            training_nonfaces(:,:,count) = patch{j};
            training_nonfaces_integral(:,:,count) = integral_image(training_nonfaces(:,:,count));
            count = count +1;
        end
    end
    
    if count > total_non_faces
        break;
    end
    
end

training_nonfaces_size = count -1;


%% load test data


h=100;
w=100;
c=1;
test_faces_list = dir('data/training_test_data/test_cropped_faces');
test_faces_size = size(test_faces_list,1);
test_faces = zeros(h,w,770);
test_faces_integral = zeros(h,w,700);
count=1;
for i =1:test_faces_size
   
    if endsWith(test_faces_list(i).name, '.bmp', 'IgnoreCase',true)
        fprintf('face: %s \n',strcat(test_faces_list(i).folder,'/',test_faces_list(i).name));
        test_faces(:,:,count) = imread(strcat(test_faces_list(i).folder,'/',test_faces_list(i).name));
        test_faces_integral(:,:,count) = integral_image(test_faces(:,:,count) );
        count = count +1;
    end
    
end
test_faces_size = count -1;

test_nonfaces_list = dir('data/training_test_data/test_nonfaces');
test_nonfaces_size = size(test_nonfaces_list,1);
test_nonfaces = zeros(h,w,120);
test_nonfaces_integral = zeros(h,w,120);
count=1;
total_test_non_faces=770;
patch = cell(total_non_faces);
for i =1:test_nonfaces_size
   
    if endsWith(test_nonfaces_list(i).name, '.jpg', 'IgnoreCase',true) && count < total_test_non_faces
        
            fprintf('nonface: %s \n',strcat(test_nonfaces_list(i).folder,'/',test_nonfaces_list(i).name));
            image = rgb2gray(imread(strcat(test_nonfaces_list(i).folder,'/',test_nonfaces_list(i).name)));
            [r,c] = size(image);
            if(r <= 100 || c <= 100)
                break;
            end
            
        for j = 1:24
            rnd_x = randperm(r-h,24);
            rnd_y = randperm(c-w,24);
            patch{j} = image((rnd_x(j):(rnd_x(j)+h-1)),(rnd_y(j):(rnd_y(j)+w-1)));
            test_nonfaces(:,:,count) = patch{j};
            test_nonfaces_integral(:,:,count) = integral_image(test_nonfaces(:,:,count));
            count = count +1;
                if count > total_test_non_faces
                    break;
                end
        end
    end
    

    
end

test_nonfaces_size = count -1;


%% weak classifiers and precompute responses

addpath 15_boosting

h=100;
w=100;
c=1;
number = 1000;
weak_classifiers = cell(1, number);
for i = 1:number
    weak_classifiers{i} = generate_classifier(h, w);
end

% pre compute responses on faces and non faces for all weak classifiers

example_number = training_faces_size + training_nonfaces_size;
labels = zeros(example_number, 1);
labels(1:training_faces_size) = 1;
labels(training_faces_size + 1:example_number) = -1;
examples = zeros(h, w, example_number);
examples (:, :, 1:training_faces_size) = training_faces_integral;
examples(:, :, training_faces_size + 1 :example_number) = training_nonfaces_integral;


classifier_number = numel(weak_classifiers);

responses =  zeros(classifier_number, example_number);

for example = 1:example_number
    integral = examples(:, :, example);
    for feature = 1:classifier_number
        classifier = weak_classifiers {feature};
        responses(feature, example) = eval_weak_classifier(classifier, integral);
    end
end


%% adaboost one classifier eval
strong_class_size_max =30;
boosted_classifier = AdaBoost(responses, labels, strong_class_size_max);

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

figure(1); plot(accuracy_all);
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
title(t,'Classifier cascade ')
xlabel(t,'\newline % TP TN FP FN' ,'fontsize',15,'VerticalAlignment','top','HorizontalAlignment','center'); 
ylabel(t,'%','fontsize',15)
hold on;
p2 = plot(TN, 'b--');
p3 = plot(FP, 'r-');
p4 = plot(FN, 'k-');
set(gca, 'XLim', [1 30]);
set(gca, 'YLim', [0 770]);
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

for t = 1:numel(TP)
  text(t, TP(t),[num2str(TP(t))])
end
legend([p1; p2; p3; p4],'True positives', 'True Negatives', 'False positives','False Negatives', 'Location','southwest');

%% adaboost cascade
%classifier_size = [3, 5, 10, 19]; % based on above plot
%classifier_size = [2, 5, 10, 19]; % based on above plot

%boosted_classifiers = cell(1, size(classifier_size,2));
%boosted_classifier = AdaBoost(responses, labels, max(classifier_size));
%% extract cascade
%classifier_size = [3, 6, 15, 19];
classifier_size = [1:30];
boosted_classifiers = struct('classifiers',[], 'threshold',{});
counter=1;
for i = classifier_size
    boosted_classifiers(counter).classifiers = boosted_classifier(1:i,:);
    boosted_classifiers(counter).threshold = cascade_thresholds(i,3);
    counter = counter+1;
end

%% find best thresholds for cascade
%classifier_size = [1 :20];
accuracy_cascade_all = zeros(size(classifier_size,2),1);
eval_cascade_positive = zeros(training_faces_size,size(classifier_size,2)) -1;
eval_cascade_negative = zeros(training_nonfaces_size,size(classifier_size,2)) -1;
layers = size(boosted_classifiers,2);
upto=1;

for i =1: training_faces_size
    upto=1;
    response=0;
    for j = 1:layers
        boosted = boosted_classifiers{j};
        linear_size = size(boosted,1);
        for weak_classifier = upto:linear_size
            classifier_index = boosted(weak_classifier, 1);
            classifier_alpha = boosted(weak_classifier, 2);
            classifier_threshold = boosted(weak_classifier, 3);
            classifier = weak_classifiers{classifier_index};
            
            response1 = responses(classifier_index, i);
            if (response1 > classifier_threshold)
                response2 = 1;
            else
                response2 = -1;
            end
            response = response + classifier_alpha * response2;
        end
        upto = linear_size +1;
            
        eval_cascade_positive(i, j) = response;
    end
end


for i =1:size(training_faces_size+1:training_nonfaces_size + training_faces_size,2)
        
    upto=1;
    response=0;
    for j = 1:layers
        boosted = boosted_classifiers{j};
        linear_size = size(boosted,1);
        for weak_classifier = upto:linear_size
            classifier_index = boosted(weak_classifier, 1);
            classifier_alpha = boosted(weak_classifier, 2);
            classifier_threshold = boosted(weak_classifier, 3);
            classifier = weak_classifiers{classifier_index};
            
            response1 =  responses(classifier_index, training_faces_size+i);
            if (response1 > classifier_threshold)
                response2 = 1;
            else
                response2 = -1;
            end
            response = response + classifier_alpha * response2;
        end
        upto = linear_size +1;
        eval_cascade_negative(i,j) = response;
    end
end
specificity = zeros(size(classifier_size,2),1);
sensitivity= zeros(size(classifier_size,2),1);
for i= 1:size(classifier_size,2)
    accuracy_cascade_all(i)= size(eval_cascade_negative(eval_cascade_negative(:,i) < 0, i),1) + size(eval_cascade_positive(eval_cascade_positive(:,i)> 0,i),1);
    specificity(i) = training_nonfaces_size/(training_nonfaces_size + size(eval_cascade_negative(eval_cascade_negative(:,i) > 0,i),1));
    sensitivity(i) = training_faces_size/(training_faces_size + size(eval_cascade_positive(eval_cascade_positive(:,i) < 0,i),1));
end
accuracy_cascade_all = accuracy_cascade_all/ example_number;




%% find cascade threshold
cascade_thresholds =  zeros(size(classifier_size,2), 3);
for i = classifier_size
[current_error, best_threshold, error] = optimize_cascade(eval_cascade_positive(:,i), 0.001);
cascade_thresholds(i,:) = [current_error, error, best_threshold ];
end

%% eval cascade new thresholds on test data

accuracy_all_t = zeros(strong_class_size_max,1);

boosted =boosted_classifiers{j};
[eval_positive_t, eval_positive_thresholded] = evaluate_cascade(test_faces_integral, boosted_classifiers, weak_classifiers, cascade_thresholds(:,3));
[eval_negative_t, eval_negative_thresholded] = evaluate_cascade(test_nonfaces_integral, boosted_classifiers, weak_classifiers, cascade_thresholds(:,3));

for acc_test = 1:strong_class_size_max 
    eval_total_t = test_faces_size  + test_nonfaces_size;
    eval_all_t = [ eval_positive_thresholded(eval_positive_thresholded(:,acc_test) >0, acc_test); eval_negative_thresholded(eval_negative_thresholded(:,acc_test) == 0, acc_test)  ];
    accuracy = size(eval_all_t,1)/eval_total_t;
    fprintf('classifiers:%d accuracy: %.3f \n',acc_test,accuracy);
    accuracy_all_t(acc_test) = accuracy;
end
 

%% plot

figure(1);
t = tiledlayout(2,2,'TileSpacing','normal', 'Padding','normal');
eval_all_t = [ eval_positive_thresholded(:,3); eval_negative_thresholded(:,3) ];
eval_all = double([ eval_positive(:, 3)>0; eval_negative(:,3) > 0  ]);
title(t,'Evaluation of cascade classifier with thresholds')
set(gca, 'YLim', [-1 2]);
set(gca, 'XLim', [0 1600]);
ax1 = nexttile;
p1 = scatter(ax1, 1:size(eval_all_t,1),eval_all_t);
ax2 = nexttile;
p2 = scatter(ax2, 1:size(eval_all,1),eval_all);
legend(ax1,[p1;],'Cascade 3 classifiers  with threshold', 'Location','southeast');
legend(ax2,[p2;],'Cascade 3 classifiers without threshold', 'Location','southeast');


hold off;

figure(2);
t = tiledlayout(2,2,'TileSpacing','normal', 'Padding','normal');
p1 = plot(accuracy_all, 'g--');
title(t,'Classifier cascade with thresholds ')
xlabel(t,'\newline Number of classifiers' ,'fontsize',15,'VerticalAlignment','top','HorizontalAlignment','center'); 
ylabel(t,'%','fontsize',15)
hold on;
p2 = plot(accuracy_all_t, 'b--');
legend([p1; p2;],'Without threshold', 'With threshold', 'Location','southwest');

%% gen cascade classifiers with threshold
classifier_size = [1, 5, 10, 19]; % based on above plot
boosted_classifiers = struct('classifiers',[], 'threshold',{});

counter=1;
for i = classifier_size
    boosted_classifiers(counter).classifiers = boosted_classifier(1:i,:);
    boosted_classifiers(counter).threshold = cascade_thresholds(i,3);
    counter = counter+1;
end

%% evaluate boosted classifier 1
test = (imread('data/training_test_data/test_face_photos/obama8.jpg'));

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 1); toc;
%figure(1); imshow(test, []);
figure(2); imshow(result, []);

positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  1, 1); toc;
figure(3); imshow(result, []);

%% evaluate boosted classifier 2
test = (imread('data/training_test_data/test_face_photos/IMG_3793.JPG'));
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 4); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  4, 1); toc;
figure(3); imshow(result, []);

%% evaluate boosted classifier 3
test = (imread('data/training_test_data/test_face_photos/IMG_3840.JPG'));

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], 4); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [100, 100], positives, negatives,  4,1); toc;
figure(3); imshow(result, []);

%% evaluate boosted classifier 4
test = (imread('data/training_test_data/test_face_photos/the-lord-of-the-rings_poster.jpg'));

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], 7); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo((test), 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], positives, negatives,  7); toc;
figure(3); imshow(result, []);

%% evaluate boosted classifier 5
test = (imread('data/training_test_data/test_face_photos/phil-jackson-and-michael-jordan.jpg'));

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), .4:0.4:1.2, boosted_classifiers, weak_classifiers, [h, w], 2); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo((test), 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], positives, negatives,  2); toc;
figure(3); imshow(result, []);

%% evaluate boosted classifier 6
test = imread('data/training_test_data/test_face_photos/DSC01418.JPG');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:2, boosted_classifiers, weak_classifiers, [h, w], 2); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo((test), 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], positives, negatives,  2); toc;
figure(3); imshow(result, []);

%% evaluate boosted classifier 7

test = imread('photos/test5.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), .5:0.5:1, boosted_classifiers, weak_classifiers, [h, w], 6); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, .5:0.5:1, boosted_classifiers, weak_classifiers, [h, w], positives, negatives,  6); toc;

figure(3); imshow(result, []);

%% evaluate boosted classifier 8 - skin

test = imread('photos/test1.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

skin = detect_skin(test, positives, negatives);
tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.4:3, boosted_classifiers, weak_classifiers, [h, w], 4); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.4:3, boosted_classifiers, weak_classifiers, [h, w], positives, negatives,  4); toc;

figure(3); imshow(result, []);

%% evaluate boosted classifier 9 - skin

test = imread('photos/test6.jpg');
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

skin = detect_skin(test, positives, negatives);
tic; [result, boxes] = boosted_detector_demo(rgb2gray(test), 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], 3); toc;
figure(2); imshow(result, []);

tic; [result, boxes] = boosted_detector_skin_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], positives, negatives,  3); toc;

figure(3); imshow(result, []);