function C = remove_holes(binary_image)
C = ~binary_image
[labels, number] = bwlabel(C, 4);
for i = 1:number
    component_image = (labels == i);
    if(component_image(1,1) == 1)
       id = i
       break
    end
end
C = ~(labels == id);