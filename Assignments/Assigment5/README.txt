Ismael Resendiz Robles (i_r174)
A04929062

Assignment 5

Task 1: Chamfer Distance
Function signature
[scores, result_image] = chamfer_search(edge_image, template, scale, number_of_results)

Input params: The function expects an edge image, a gray scale template, a numeric scale, and numeric number of results. 
Output params: scores contains chamfer scores, result_image an image with the bounding box where the min list of scores were detected.

Testing: Figure 1. Results shows that the first 2 min chamfer distances, do not match the expected shape in the figure. It's only until the 3rd results where I got the shape detected. Performance and accuracy can be improved using skin detection to limit the search area in the figure, hence avoid getting mislead results. 

Task 2: Skin Chamfer Distance
Function Signature
[scores, result_image] = skin_chamfer_search(color_image, edge_image, template, scale, number_of_results)

Input params: The function expects a color image, an edge image corresponding to the image color, a gray scale template, a numeric scale, and numeric number of results. 
Output params: scores contains chamfer scores, result_image an image with the bounding box where the min list of scores were detected.

Testing: Figure 1. First step is to identify skin areas by running detect_skin function. With the resulting image, we now can extract the areas where the edge_image intersects. The intersection can be cropped to the areas with information (non zero) and pass it to the chamfer_search function in task 1. Then the image can be reshaped back to the initial size including the bounding box. The results shows that the first 3 min chamfer distances are near the center of the image hand. Also the performance is improved by ~30%, since there is the size of the image was considerable reduced.