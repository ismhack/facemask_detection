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


%% adaboost one classifier
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

figure(1); plot(accuracy_all);

%% adaboost cascade
classifier_size = [3, 5, 10, 20];
boosted_classifiers = cell(1, size(classifier_size,2));
boosted_classifier = AdaBoost(responses, labels, max(classifier_size));
%% extract cascade
classifier_size = [1, 5, 15, 20];
counter=1;
for i = classifier_size
    boosted_classifiers{counter} = boosted_classifier(1:i,:);
    counter = counter+1;
end

%% evaluate boosted classifier 1
test = rgb2gray(imread('data/training_test_data/test_face_photos/obama8.jpg'));

tic; [result, boxes] = boosted_detector_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], 1); toc;
%figure(1); imshow(test, []);
figure(2); imshow(result, []);

%% evaluate boosted classifier 2
test = rgb2gray(imread('data/training_test_data/test_face_photos/IMG_3793.JPG'));

tic; [result, boxes] = boosted_detector_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], 4); toc;
figure(1); imshow(test, []);
figure(2); imshow(result, []);

%% evaluate boosted classifier 3
test = rgb2gray(imread('data/training_test_data/test_face_photos/IMG_3840.JPG'));

tic; [result, boxes] = boosted_detector_demo(test, 1:0.5:3, boosted_classifiers, weak_classifiers, [h, w], 4); toc;
figure(1); imshow(test, []);
figure(2); imshow(result, []);

%% evaluate boosted classifier 4
test = rgb2gray(imread('data/training_test_data/test_face_photos/the-lord-of-the-rings_poster.jpg'));

tic; [result, boxes] = boosted_detector_demo(test, .5:0.5:1, boosted_classifiers, weak_classifiers, [h, w], 7); toc;
figure(1); imshow(test, []);
figure(2); imshow(result, []);

%% evaluate boosted classifier 5
test = rgb2gray(imread('data/training_test_data/test_face_photos/phil-jackson-and-michael-jordan.jpg'));

tic; [result, boxes] = boosted_detector_demo(test, .4:0.4:1.2, boosted_classifiers, weak_classifiers, [h, w], 2); toc;
figure(1); imshow(test, []);
figure(2); imshow(result, []);

%% evaluate boosted classifier 6
test = read_gray('data/training_test_data/test_face_photos/DSC01418.JPG');

tic; [result, boxes] = boosted_detector_demo(test, 0.1:0.1:1, boosted_classifiers, weak_classifiers, [h, w], 5); toc;
figure(1); imshow(test, []);
figure(2); imshow(result, []);

