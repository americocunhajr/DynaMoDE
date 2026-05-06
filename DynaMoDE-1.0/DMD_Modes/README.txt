To the user:

"Dmd_sv.m" does the Singular Value Decomposition (SVD) for the dynamic fields, 
and store the results into the files: 
"ack_sv.mat", "ras_sv.mat", "sch_sv.mat", "grie_sv.mat" 

"Plot_sv.m" plots the singular values from the svd files
 and the truncation region chosen by the user

--------------------------------------------------------

"Dmd_modes.m" computes the modes of the dynamic fields, 
and store the results into the files: 
"ack_modes.mat", "ras_modes.mat", "sch_modes.mat", "grie_modes.mat" 

"Plot_modes.m" plots the modes one by one and/or in a tiled layout and/or 
plot the frequencies from the modes files,
the figures can be recorded using the "rec" option

----------------------------------------------------------
"dmd.m", "pre_proc.m", "post_proc.m" are the core of the algorithm and doensn't must be changed, 
unless you want to improve code performance.