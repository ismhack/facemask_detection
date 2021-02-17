clear;

%%Module 1
frame1 = double(imread('../data/training_A.bmp'));
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

% Module 1 evaluation
evaluation = double(imread('../data/test.bmp'));
[rows,cols, bands] = size(frame20);

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

figure(4); imshow(skin_detection, []);
figure(4); imshow(skin_detection > 10, []);

max = max(max(skin_detection));
min = min(min(skin_detection));
range = (0:5:100)

positive = zeros(size(range,2))
negative = zeros(size(range,2))
for i = 1:size(range,2)
    threshold = (range(i) * (max - min) / 100) + min
    [positive_per, negative_per] = eval_module(skin_detection, threshold)
    positive(i) =  positive_per
    negative(i) = negative_per
    
end

%% Module 2
frame1 = double(imread('../data/training_B.bmp'));
% finding a training sample
sample1 = frame1(189:230, 213:293, :);
sample2 = frame1(376:423, 63:120, :);
sample3 = frame1(413:471, 404:455, :);

%figure(2); imshow(sample1 / 255);
%figure(3); imshow(sample2 / 255);
%figure(4); imshow(sample2 / 255);
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

r_mean = mean(sample_red2);
g_mean = mean(sample_green2);
r_std = std(sample_red2);
g_std = std(sample_green2);

%% Plotting

close all;
figure(1);
plot(positive, negative, 'k-');
hold on;
plot(positive, negative/2, 'r--');
plot(positive, negative/4, 'b:');
set(gca, 'XLim', [0 100]);
set(gca, 'YLim', [0 100]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
xticks(range)
yticks(range)
set(gca, 'PlotBoxAspectRatio', [1 1 1]);
legend('method1', 'method2', 'method3', 'Location', 'NorthWest');