function result = central_moment(shape, i, j)
[r,c] = size(shape);
shape = double(shape);
M10 = raw_moment(shape, 1, 0);
M00 = raw_moment(shape, 0, 0);
M01 = raw_moment(shape, 0, 1);

x_centroid = M10/M00;
y_centroid = M01/M00;

mu = 0;
for x = 1:r
    for y = 1:c
        mu = mu + (x - x_centroid)^i * (y - y_centroid)^j * shape(x, y);
    end
end

result = mu;