To the user:

"Dmd_recons.m" generate the reconstructed field files 
"ack_rec_field.mat", "ras_rec_field.mat", "sch_rec_field.mat", "grie_rec_field.mat"
using the original dynamic fields:
"ack_dyn_field.mat", "ras_dyn_field.mat", "sch_dyn_field.mat", "grie_dyn_field.mat"

"Plot_rec_field.m" use the original and reconstructed field files to plot a comparison between them
in a surface plot, a contour plot and a instants comparison plot 
that can be saved using the "rec" option in the code.

"dmd.m", "pre_proc.m", "post_proc.m" are the core of the algorithm and doensn't must be changed, 
unless you want to improve code performance.