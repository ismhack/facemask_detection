function [result, start_frame, end_frame] = dtw2(seq1, seq2)

m = size(seq1,2);
n = size(seq2,2);

scores = zeros(m+1,n);
scores(1, :) = 0; % sink
scores(2,1) = euclidian_distance(seq1(:,1), seq2(:,1));

for i=2:m+1
    scores(i, 1) = scores(i-1, 1) + euclidian_distance(seq1(:,i-1), seq2(:,1));
end

for j=2:n
    scores(2, j) = scores(1, j-1) + euclidian_distance(seq1(:,1), seq2(:,j));
end

for i = 2:m + 1
    for j = 2:n
        scores(i, j) = euclidian_distance(seq1(:,i-1), seq2(:,j)) + min([scores(i-1, j) scores(i, j-1) scores(i-1, j-1)]);
    end
end

start_frame_value = min(scores(2,:));
start_frame = find(scores(2,:) == start_frame_value);
result = min(scores(m+1,:));
end_frame = find(scores(m+1,:) == result);