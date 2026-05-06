To the user:

"Stat_field.m" is used to generate the static field data stored in the files: 
"ack_stat_field.mat", "ras_stat_field.mat", "sch_stat_field.mat", "grie_stat_field.mat".

"Dyn_field.m" is used to generate the dynamic field data stored in the files: 
"ack_dyn_field.mat", "ras_dyn_field.mat", "sch_dyn_field.mat", "grie_dyn_field.mat".

If you want to modify the domain limits, do it in the files: "Stat_field.m", "Dyn_field.m".

"Plot_stat_field" use the static field data stored in the files to plot the static fields.

"Plot_dyn_field" use the dynamic field data stored in the files to plot the dynamic fields.

"ackley.m", "rastrigin.m", "schaffer.m", "griewank.m" are the core of the fields generation,
used in both "Stat_field.m", "Dyn_field.m".
They are programmed following the test function definition and doens't need to be changed,
unless you want to improve the code performance.