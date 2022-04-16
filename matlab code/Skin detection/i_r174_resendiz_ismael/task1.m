clear;

%% Evaluation setup

evaluation = double(imread('test.bmp'));
[rows,cols, bands] = size(evaluation);
range = (0:5:100)

%% Module 1
frame1 = double(imread('training_A.bmp'));
%figure(1); imshow(frame1 / 255);
% finding a training sample
%figure(2); imshow(frame1(122:150, 297:338, :) / 255);
%figure(3); imshow(frame1(246:265, 117:145, :) / 255);

sample1 = frame1(122:150, 297:338, :);
sample2 = frame1(246:265, 117:145, :);

sample_red = sample1(:, :, 1);
sample_green = sample1(:, :, 2);
sample_blue = sample1(:, :, 3);

sample2_red = sample2(:, :, 1);
sample2_green = sample2(:, :, 2);
sample2_blue = sample2(:, :, 3);

sample_red = sample_red(:);
sample_green = sample_green(:);
sample_blue = sample_blue(:);

sample2_red = sample2_red(:);
sample2_green = sample2_green(:);
sample2_blue = sample2_blue(:);

sample_red = [sample_red; sample2_red]
sample_green = [sample_green; sample2_green]
sample_blue = [sample_blue; sample2_blue]

sample_total = sample_red + sample_green + sample_blue;
sample_red2 = sample_red ./ sample_total;
sample_red2(isnan(sample_red2)) = 0; % when (R+G+B) == 0, a division by 0 can result in a NaN
sample_green2 = sample_green ./ sample_total;
sample_green2(isnan(sample_green2)) = 0;

r_mean = mean(sample_red2);
g_mean = mean(sample_green2);
r_std = std(sample_red2);
g_std = std(sample_green2);

% Evaluating with test image
skin_detection = zeros(rows, cols);
for row = 1:rows
    for col = 1:cols
        red = evaluation(row, col, 1);
        green = evaluation(row, col, 2);
        blue = evaluation(row, col, 3);
    
        sum = red+green+blue;
        if sum > 0
            r = red / sum;
            g = green / sum;
        else
            r = 0;
            g = 0;
        end
        
        r_prob = gaussian_probability(r_mean, r_std, r);
        g_prob = gaussian_probability(g_mean, g_std, g);
        prob = r_prob * g_prob;
        skin_detection(row, col) = prob;
    end
end

%figure(4); imshow(skin_detection, []);
%figure(4); imshow(skin_detection > 10, []);

% Determining range of values in test data
maxVal = max(max(skin_detection));
minVal = min(min(skin_detection));

positive = zeros(size(range,2));
negative = zeros(size(range,2));
threshold = zeros(size(range,2));
% Evaluate model with percentage threshold 0 : 5 : 100.
for i = 1:size(range,2)
    threshold(i) = (range(i) * (maxVal - minVal) / 100) + minVal;
    [positive_per, negative_per] = eval_module(skin_detection, threshold(i));
    positive(i) =  positive_per;
    negative(i) = negative_per;
    
end
results1 = [threshold(:,1), positive(:,1), negative(:,1)]

%% Module 2
frame1 = double(imread('training_B.bmp'));
% finding a training sample
sample1 = frame1(189:230, 213:293, :);
sample2 = frame1(376:423, 63:120, :);
sample3 = frame1(413:471, 404:455, :);

%figure(2); imshow(sample1 / 255);
%figure(3); imshow(sample2 / 255);
%figure(4); imshow(sample3 / 255);
sample_red = sample1(:, :, 1);
sample_green = sample1(:, :, 2);
sample_blue = sample1(:, :, 3);

sample2_red = sample2(:, :, 1);
sample2_green = sample2(:, :, 2);
sample2_blue = sample2(:, :, 3);

sample3_red = sample3(:, :, 1);
sample3_green = sample3(:, :, 2);
sample3_blue = sample3(:, :, 3);

sample_red = sample_red(:);
sample_green = sample_green(:);
sample_blue = sample_blue(:);

sample2_red = sample2_red(:);
sample2_green = sample2_green(:);
sample2_blue = sample2_blue(:);

sample3_red = sample3_red(:);
sample3_green = sample3_green(:);
sample3_blue = sample3_blue(:);

sample_red = [sample_red; sample2_red; sample3_red]
sample_green = [sample_green; sample2_green; sample3_green]
sample_blue = [sample_blue; sample2_blue; sample3_blue]

sample_total = sample_red + sample_green + sample_blue;
sample_red2 = sample_red ./ sample_total;
sample_red2(isnan(sample_red2)) = 0; % when (R+G+B) == 0, a division by 0 can result in a NaN
sample_green2 = sample_green ./ sample_total;
sample_green2(isnan(sample_green2)) = 0;

r_mean2 = mean(sample_red2);
g_mean2 = mean(sample_green2);
r_std2 = std(sample_red2);
g_std2 = std(sample_green2);


% Evaluating with test image
skin_detection2 = zeros(rows, cols);
for row = 1:rows
    for col = 1:cols
        red = evaluation(row, col, 1);
        green = evaluation(row, col, 2);
        blue = evaluation(row, col, 3);
    
        sum = red+green+blue;
        if sum > 0
            r = red / sum;
            g = green / sum;
        else
            r = 0;
            g = 0;
        end
        
        r_prob = gaussian_probability(r_mean2, r_std2, r);
        g_prob = gaussian_probability(g_mean2, g_std2, g);
        prob = r_prob * g_prob;
        skin_detection2(row, col) = prob;
    end
end


% Determining range of values in test data
maxVal = max(max(skin_detection2));
minVal = min(min(skin_detection2));

positive2 = zeros(size(range,2));
negative2 = zeros(size(range,2));
threshold = zeros(size(range,2));
% Evaluate model with percentage threshold 0 : 5 : 100.
for i = 1:size(range,2)
    threshold(i) = (range(i) * (maxVal - minVal) / 100) + minVal;
    [positive_per, negative_per] = eval_module(skin_detection2, threshold(i));
    positive2(i) =  positive_per;
    negative2(i) = negative_per;
end

results2 = [threshold(:,1), positive2(:,1), negative2(:,1)]

%% Module 3

negative_histogram = read_double_image('negatives.bin');
positive_histogram = read_double_image('positives.bin');

skin_detection3 = detect_skin(evaluation, positive_histogram,  negative_histogram);

% Determining range of values in test data
maxVal = max(max(skin_detection3));
minVal = min(min(skin_detection3));

positive3 = zeros(size(range,2));
negative3 = zeros(size(range,2));
threshold = zeros(size(range,2));
% Evaluate model with percentage threshold 0 : 5 : 100.
for i = 1:size(range,2)
    threshold(i) = (range(i) * (maxVal - minVal) / 100) + minVal;
    [positive_per, negative_per] = eval_module(skin_detection3, threshold(i));
    positive3(i) =  positive_per;
    negative3(i) = negative_per;
end
results3 = [threshold(:,1), positive3(:,1), negative3(:,1)]

%% Plotting

write_double_matrix(results1, 'results1.bin')
write_double_matrix(results2, 'results2.bin')
write_double_matrix(results3, 'results3.bin')

close all;
figure(1);
t = tiledlayout(2,2,'TileSpacing','normal', 'Padding','normal');
p1 = plot(positive, negative, 'k-');
title(t,'Skind Detection')
xlabel(t,'\newline % Skin pixels detected' ,'fontsize',15,'VerticalAlignment','top','HorizontalAlignment','center'); 
ylabel(t,'% non-Skin pixels detected','fontsize',15)
hold on;
p2 = plot(positive2, negative2, 'r--');
p3 = plot(positive3, negative3, 'b:');
set(gca, 'XLim', [0 105]);
set(gca, 'YLim', [0 105]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
xticks(range)
yticks(range)
set(gca, 'PlotBoxAspectRatio', [1 1 1]);
h = [p1(1);p2(1);p3(1);];
legend(h,'Module 1', 'Module 2', 'Module 3', 'Location','southwest');
