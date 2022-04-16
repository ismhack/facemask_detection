function result = normalized_moment(shape, i, j)
mu00 = central_moment(shape, 0, 0);
muij = central_moment(shape, i, j);

if((i + j) >= 2)
    nij = muij / (mu00^(1 + (i + j)/2));
else
    nij = muij / mu00;
end

result = nij;