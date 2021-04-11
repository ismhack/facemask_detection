function result = dtw(seq1, seq2)

m = size(seq1,2);
n = size(seq2,2);

scores = zeros(m,n);
scores(1,1) = euclidian_distance(seq1(:,1), seq2(:,1));

for i=2:m
    scores(i, 1) = scores(i-1, 1) + euclidian_distance(seq1(:,i), seq2(:,1));
end

for j=2:n
    scores(1, j) = scores(1, j-1) + euclidian_distance(seq1(:,1), seq2(:,j));
end


for i = 2:m
    for j = 2:n
        scores(i, j) = euclidian_distance(seq1(:,i), seq2(:,j)) + min([scores(i-1, j) scores(i, j-1) scores(i-1, j-1)]);
    end
end

result = scores(m,n);