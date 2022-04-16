%% load train faces and calc integral image

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

strong_class_size_max =50;
boosted_classifier = AdaBoost(responses, labels, strong_class_size_max);
classifier_size = [1, 5, 10, 20]; % based on best accuracy

boosted_classifiers = struct('classifiers',[], 'threshold',{});

counter=1;
for i = classifier_size
    boosted_classifiers(counter).classifiers = boosted_classifier(1:i,:);
    boosted_classifiers(counter).threshold = 0;
    counter = counter+1;
end

%%

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
        boosted = boosted_classifiers(j);
        linear_size = size(boosted.classifiers,1);
        for weak_classifier = upto:linear_size
            classifier_index = boosted.classifiers(weak_classifier, 1);
            classifier_alpha = boosted.classifiers(weak_classifier, 2);
            classifier_threshold = boosted.classifiers(weak_classifier, 3);
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
        boosted = boosted_classifiers(j);
        linear_size = size(boosted.classifiers,1);
        for weak_classifier = upto:linear_size
            classifier_index = boosted.classifiers(weak_classifier, 1);
            classifier_alpha = boosted.classifiers(weak_classifier, 2);
            classifier_threshold = boosted.classifiers(weak_classifier, 3);
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
for i = 1:length(classifier_size)
[current_error, best_threshold, error] = optimize_cascade(eval_cascade_positive(:,i), 0.001);
cascade_thresholds(i,:) = [current_error, error, best_threshold ];
end

%% gen cascade classifiers with threshold

boosted_classifiers = struct('classifiers',[], 'threshold',{});

counter=1;
for i =  1:length(classifier_size)
    boosted_classifiers(counter).classifiers = boosted_classifier(1:i,:);
    boosted_classifiers(counter).threshold = cascade_thresholds(i,3);
    counter = counter+1;
end

disp('Adaboost Training complete');
