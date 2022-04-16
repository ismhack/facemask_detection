Ismael Resendiz Robles (i_r174)
A04929062

Assignment 10

Task 1: Calculate the Dynamic Time Warping
Function Signature: result = dtw(sequence1, sequence2)
Returns: the min cost to connect the 2 sequences given in the parameters.
Description: Uses the DTW algorithm to calculate the reflection of sequence one to sequence two. 


Task 2: Calculate DTW where the start and end states are unknown
Function signature: [result, start_frame, end_frame] = dtw2(sequence1, sequence2) 
Returns: the min cost to connect the 2 sequences given in the parameters, the start and end sequences.
Description: Similar than task 1 calculates DTW, but insert a sink state in the scores matrix and choose the smaller element in that row as the start sequence. Uses the min element from the last row in the scores matrix to determine the end of the sequence.
