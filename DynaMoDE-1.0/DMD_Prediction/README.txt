To the user:

"Dmd_predict.m" generate the predicted field files 
"ack_pred_field.mat", "ras_pred_field.mat", "sch_pred_field.mat", "grie_pred_field.mat"
using the original dynamic fields:
"ack_dyn_field.mat", "ras_dyn_field.mat", "sch_dyn_field.mat", "grie_dyn_field.mat"

"Plot_pred_field.m" use the original and predicted field files to plot a comparison between them
in a surface plot, a contour plot and a instants comparison plot 
that can be saved using the "rec" option in the code.

"dmd_pred.m" is the core of the algorithm and here you can set the prediction horizon,
the standard value is the 20% further instants from the original dynamic field instants,
the theory reveals that the horizon for a good prediction must be kept short

"pre_proc.m", "post_proc.m" are the pre-processing and post-processing steps 
and doensn't must be changed, unless you want to improve code performance.