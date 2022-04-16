%% extract face and nonface patches testing
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');
class1 = "without_mask"; % applicable for the kaggle data
class2 = "with_mask";
class3 = "mask_weared_incorrect";
im_dataset = [];
im_labels = [];
h=100;
w=100;
im_dataset = uint8(im_dataset);
count = 1;
facemask_eval_count =  zeros(100, 2);
facemask_counts =  zeros(100, 2);
facemask_data_bb= zeros(1, 4);
facemask_eval_bb = zeros(1, 4);
incorrectly_worn_count=0;
for i = 0:99
    S = readstruct(['data/eval_cnn_photos/facemask_annotations/maksssksksss' num2str(i, '%d') '.xml']);
    [I, map] = imread(['data/eval_cnn_photos/facemask_test/maksssksksss' num2str(i, '%d') '.png']);
    I = uint8(255 * mat2gray(I));
    frames_size = size(S.object, 2);
    count_face= 0;
    count_facemask=0;
    incorrectly_worn_count=0;
    count=0;
    for j = 1: frames_size
        %I = draw_rectangle1(I,S.object(i).bndbox.ymax, S.object(i).bndbox.ymin, S.object(i).bndbox.xmin, S.object(i).bndbox.xmax);
        top = S.object(j).bndbox.ymax;
        bottom = S.object(j).bndbox.ymin;
        left = S.object(j).bndbox.xmin;
        right = S.object(j).bndbox.xmax;
        face = I(bottom:top-1, left:right-1, 1:3);
        
        if size(face,1) < 36 || size(face,2) < 36
            continue;
        end
        
        if S.object(j).name == class1
            class =class1;
            className= "1";
            count_face= count_face+1;
            facemask_counts(i+1,1) = facemask_counts(i+1,1) +1;
            %facemask_data_bb(count,:) = [top, bottom,left,right];
        elseif S.object(j).name == class2 || S.object(j).name == class3
            class = class2;
            className= "2";
            count_facemask= count_facemask+1;
            facemask_counts(i+1,2) = facemask_counts(i+1,2) +1;
            %facemask_data_bb(count,:) = [top, bottom,left,right];
        else
            class = "0";
            incorrectly_worn_count = incorrectly_worn_count +1;
            
        end
        fprintf('[%d %d %d] %d i:%d \n', size(face), count, i);
        %im_dataset(:,:,:,count,S) = uint8(imresize(face,[h w]));
        %imwrite( im_dataset(:,:,:,count),strcat('data/', className ,'/', string(count),'.png'),'png');
        %im_labels(S, count) = className;
        count = count +1;
    end
    [boxes, detections] = evaluate_facemask_detector(I,0.3:0.2:1.5,boosted_classifiers, weak_classifiers,...
        gnet,  [100, 100], positives, negatives,  count );
    
    facemask_eval_count(i+1,:) = detections;
    c = 1;
    for j = size(facemask_eval_bb,1)+1:length(boxes) + size(facemask_eval_bb,1)
        if boxes(c).nonMax == 1
            facemask_eval_bb(j, :) = [boxes(c).coords(1),...
                boxes(c).coords(2), boxes(c).coords(3), boxes(c).coords(4)];
        end
        c = c+1;
    end
    
end


%% eval data
disp('groud truth faces - facemask');
sum(facemask_counts, 1)
disp('evaluation faces - facemask');
sum(facemask_eval_count,1)

%% test essembling face detector and facemask classifier - Gnet 
test = imread('data/eval_cnn_photos/facemask_test/maksssksksss21.png');
test = uint8(255 * mat2gray(test));

tic; [boxes, detections] = evaluate_facemask_detector(test, 0.2:0.2:2,boosted_classifiers, weak_classifiers,...
        gnet,  [100, 100], positives, negatives,  5); toc;
result= test;
for i = 1:length(boxes)
    if boxes(i).nonMax == 1
        if boxes(i).cnnFaceMaskProb >= 0.5
            result = drawRectangle(result, boxes(i).coords, [0, 255, 0]);
            
        else
            result = drawRectangle(result, boxes(i).coords, [255, 0, 0]);
        end
    end
end

figure(3); imshow(result, []);


test = imread('data/eval_cnn_photos/facemask_test/maksssksksss40.png');
test = uint8(255 * mat2gray(test));
tic; [boxes, detections] = evaluate_facemask_detector(test, 0.2:0.2:2, boosted_classifiers, weak_classifiers,...
    gnet, [100, 100], positives, negatives,  5); toc;
result= test;
for i = 1:length(boxes)
    if boxes(i).nonMax == 1
        if boxes(i).cnnFaceMaskProb >= 0.5
            result = drawRectangle(result, boxes(i).coords, [0, 255, 0]);
        else
            result = drawRectangle(result, boxes(i).coords, [255, 0, 0]);
        end
    end
end

figure(2); imshow(result, []);

%% squeezenet

test = imread('data/eval_cnn_photos/facemask_test/maksssksksss84.png');
test = uint8(255 * mat2gray(test));
tic; [boxes, detections] = evaluate_facemask_detector(test, 1, boosted_classifiers, weak_classifiers,...
    sqnet, [100, 100], positives, negatives,  3); toc;
result= test;
for i = 1:length(boxes)
    if boxes(i).nonMax == 1
        if boxes(i).cnnFaceMaskProb >= 0.5
            result = drawRectangle(result, boxes(i).coords, [0, 255, 0]);
        else
            result = drawRectangle(result, boxes(i).coords, [255, 0, 0]);
        end
    end
end

figure(4); imshow(result, []);

test = imread('data/eval_cnn_photos/facemask_test/maksssksksss80.png');
test = uint8(255 * mat2gray(test));
tic; [boxes, detections] = evaluate_facemask_detector(test, 1, boosted_classifiers, weak_classifiers,...
    sqnet, [100, 100], positives, negatives,  1); toc;
result= test;
for i = 1:length(boxes)
    if boxes(i).nonMax == 1
        if boxes(i).cnnFaceMaskProb >= 0.5
            result = drawRectangle(result, boxes(i).coords, [0, 255, 0]);
        else
            result = drawRectangle(result, boxes(i).coords, [255, 0, 0]);
        end
    end
end

figure(5); imshow(result, []); 

