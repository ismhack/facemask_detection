seq1a = [0.30 0.40 0.50 0.60 0.50 0.40 0.30 0.40 0.50 0.60;
0.80 0.90 0.90 0.80 0.60 0.50 0.40 0.40 0.40 0.40]; 

seq2a = [0.29 0.36 0.46 0.58 0.53 0.46 0.36 0.29 0.43 0.54 0.59 0.6077;
0.80 0.89 0.89 0.81 0.66 0.57 0.47 0.40 0.40 0.40 0.42 0.4299];


seq1b = [0.10 0.17 0.24 0.31 0.36 0.40 0.42 0.46 0.50 0.57 0.64 0.71 0.74 0.77 0.81  0.83  0.86 0.90 0.95 0.99;
0.30 0.38 0.49 0.54 0.54 0.47 0.37 0.29 0.25 0.26 0.26 0.26 0.31 0.38 0.38 0.32 0.25 0.25 0.24 0.25];

seq2b = [0.13 0.18 0.21 0.25 0.29 0.32 0.38 0.42 0.42 0.45 0.47 0.51 0.56 0.63 0.67 0.72 0.74 0.77 0.79 0.81 0.83 0.87 0.92 0.97;
0.29 0.31 0.32 0.38 0.47 0.52 0.54 0.52 0.46 0.37 0.32 0.28 0.26 0.26 0.26 0.35 0.38 0.38 0.34 0.28 0.25 0.25 0.26 0.24];

d = dtw(seq1a, seq2a);

d = dtw(seq1b, seq2b);

%% dtw2

seq1c = [0.69 0.72 0.72 0.76 0.81 0.82 0.84 0.87;
0.26 0.26 0.30 0.38 0.38 0.30 0.26 0.25];


seq2c = [0.10 0.17 0.24 0.31 0.36 0.40 0.42 0.46 0.50 0.57 0.64 0.71 0.74 0.77 0.81 0.83 0.86 0.90 0.95 0.99;
0.30 0.38 0.49 0.54 0.54 0.47 0.37 0.29 0.25 0.26 0.26 0.26 0.31 0.38 0.38 0.32 0.25 0.25 0.24 0.25];

[result, start_frame, end_frame]  =  dtw2(seq1c, seq2c);
