clear;


%% Evaluation setup

evaluation = double(imread('test.bmp'));
[rows,cols, bands] = size(evaluation);
range = (0:5:100)

%% Training
frame1 = double(imread('training_B.bmp'));
% finding a training sample
sample1 = double(frame1(189:230, 213:293, :));
sample2 = double(frame1(376:423, 63:120, :));
sample3 = double(frame1(413:471, 404:455, :));
sample_nonskin = double(frame1(1:480, 460:640, :));
sample_nonskin2 = double(frame1(340:392, 260:410, :));
sample_nonskin3 = double(frame1(1:63, 1:480, :));

%% Histograms
binSize = 8
factor = 256/binSize
positive_bin = zeros([binSize binSize binSize]);
negative_bin = zeros([binSize binSize binSize]);

rows = size(sample1, 1);
cols = size(sample1, 2);
for row= 1 : rows
    for col = 1 : cols
        pixel = double(reshape(sample1(row,col,:),[1 3]));
        pixel=floor(pixel/factor)+1;
        positive_bin(pixel(1), pixel(2), pixel(3)) = positive_bin(pixel(1), pixel(2), pixel(3)) +1;
    end
   
end

rows = size(sample2, 1);
cols = size(sample2, 2);
for row= 1 : rows
    for col = 1 : cols
        pixel = double(reshape(sample2(row,col,:),[1 3]));
        pixel=floor(pixel/factor)+1;
        positive_bin(pixel(1), pixel(2), pixel(3)) = positive_bin(pixel(1), pixel(2), pixel(3)) + 1;
    end
   
end

rows = size(sample3, 1);
cols = size(sample3, 2);
for row= 1 : rows
    for col = 1 : cols
        pixel = double(reshape(sample3(row,col,:),[1 3]));
        pixel=floor(pixel/factor)+1;
        positive_bin(pixel(1), pixel(2), pixel(3)) = positive_bin(pixel(1), pixel(2), pixel(3)) +1; 
    end
   
end

% Sample no skin
rows = size(sample_nonskin, 1);
cols = size(sample_nonskin, 2);
for row= 1 : rows
    for col = 1 : cols
        pixel = double(reshape(sample_nonskin(row,col,:),[1 3]));
        pixel=floor(pixel/factor)+1;
        negative_bin(pixel(1), pixel(2), pixel(3)) = negative_bin(pixel(1), pixel(2), pixel(3))  +1;
    end
   
end
rows = size(sample_nonskin2, 1);
cols = size(sample_nonskin2, 2);
for row= 1 : rows
    for col = 1 : cols
        pixel = double(reshape(sample_nonskin2(row,col,:),[1 3]));
        pixel=floor(pixel/factor)+1;
        negative_bin(pixel(1), pixel(2), pixel(3)) = negative_bin(pixel(1), pixel(2), pixel(3))  +1;
    end
   
end
rows = size(sample_nonskin3, 1);
cols = size(sample_nonskin3, 2);
for row= 1 : rows
    for col = 1 : cols
        pixel = double(reshape(sample_nonskin3(row,col,:),[1 3]));
        pixel=floor(pixel/factor)+1;
        negative_bin(pixel(1), pixel(2), pixel(3)) = negative_bin(pixel(1), pixel(2), pixel(3))  +1;
    end
   
end
%% 
%positive_bin_total = positive_bin(:);
%negative_bin_total=negative_bin(:);

%negative_bin=negative_bin./sum(negative_bin_total);
%positive_bin=positive_bin./sum(positive_bin_total);

%% Evaluate skin detection
skin_detection = detect_skin(evaluation, positive_bin, negative_bin);

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

results = [threshold(:,1), positive(:,1), negative(:,1)];

%% Plot

results1 = read_double_matrix('results1.bin');
results2 = read_double_matrix('results2.bin');
results3 = read_double_matrix('results3.bin');

close all;
figure(1);
t = tiledlayout(2,2,'TileSpacing','normal', 'Padding','normal');
p1 = plot(results1(:,2), results1(:,3), 'k-');
title(t,'Skind Detection')
xlabel(t,'\newline % Skin pixels detected' ,'fontsize',15,'VerticalAlignment','top','HorizontalAlignment','center'); 
ylabel(t,'% non-Skin pixels detected','fontsize',15)
hold on;
p2 = plot(results2(:,2), results2(:,3), 'r--');
p3 = plot(results3(:,2), results3(:,3), 'b:');
p4 = plot(results(:,2), results(:,3), 'g-');
set(gca, 'XLim', [0 105]);
set(gca, 'YLim', [0 105]);
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
xticks(range)
yticks(range)
set(gca, 'PlotBoxAspectRatio', [1 1 1]);
h = [p1(1);p2(1);p3(1); p4(1);];
legend(h,'Module 1', 'Module 2', 'Module 3','Custom Bin', 'Location','southwest');
