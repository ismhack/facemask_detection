function result = raw_moment(shape, i, j)
[r,c] = size(shape);
M = 0;
for x = 1:r
    for y = 1:c
        M = M + x^i * y^j* shape(x, y);
    end
end
result = M;