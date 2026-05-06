To the User:

"Sim_trunc.m" generates a list of similarity between original and reconstructed files and
and their associated truncation assumed and save the results into the files:
"ack_sim_trunc.mat", "ras_sim_trunc.mat", "sch_sim_trunc.mat", "grie_sim_trunc.mat"

"Plot_sim_trunc.m" plot these dataset of truncation and similarity 
in order to evaluate how many modes are necessary to obtain a good reconstruction,
also highlights the region of truncation chosen

"dmd.m", "pre_proc.m", "post_proc.m" are the core of the algorithm and doensn't must be changed, 
unless you want to improve code performance.