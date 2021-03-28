function result = hu_moment(shape, i)

switch i
    case 1
        result = normalized_moment(shape, 2, 0) + normalized_moment(shape, 0, 2);
    case 2
        result = (normalized_moment(shape, 2, 0) - normalized_moment(shape, 0, 2))^2 ...
            + (2*(normalized_moment(shape, 1, 1)))^2;
    case 3
        result = (normalized_moment(shape, 3, 0) - 3*normalized_moment(shape, 1, 2))^2 ...
            + (3*normalized_moment(shape, 2, 1) - normalized_moment(shape, 0, 3))^2;
    case 4
        result = (normalized_moment(shape, 3, 0) + normalized_moment(shape, 1, 2))^2 ...
            + (normalized_moment(shape, 2, 1) + normalized_moment(shape, 0, 3))^2;
    case 5
        n30 = normalized_moment(shape, 3, 0);
        n03 = normalized_moment(shape, 0, 3);
        n12 = normalized_moment(shape, 1, 2);
        n21 = normalized_moment(shape, 2, 1);
         result = ((n30 - 3*n12)*(n30 + n12))*((n30 + n12)^2 - 3*((n21 + n03)^2));
         result = result + (3*n21 - n03)*(n21 + n03)* (3*((n30 + n12)^2) - (n21 + n03)^2);
    case 6
        n30 = normalized_moment(shape, 3, 0);
        n03 = normalized_moment(shape, 0, 3);
        n12 = normalized_moment(shape, 1, 2);
        n11 = normalized_moment(shape, 1, 1);
        n21 = normalized_moment(shape, 2, 1);
        n02 = normalized_moment(shape, 0, 2);
        n20 = normalized_moment(shape, 2, 0);
         result = (n20 - n02)*...
             ((n30 + n12)^2 - (n21 + n03)^2) + ...
             (4*n11)*(n30 + n12)*(n21 + n03);
    case 7
        n30 = normalized_moment(shape, 3, 0);
        n03 = normalized_moment(shape, 0, 3);
        n12 = normalized_moment(shape, 1, 2);
        n21 = normalized_moment(shape, 2, 1);
        result = (3*n21 - n03)*(n30 +n12)*((n30 +n12)^2 - 3*(n21 + n03)^2);
        result = result - (n30 - 3*n12)*(n21 +n03)*(3*((n30+n12)^2) - (n21+n03)^2);
    otherwise
        result=0;
        
end