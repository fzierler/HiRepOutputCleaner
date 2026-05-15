using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

file_in  = "/home/fabian/Documents/Physics/Analysis/fundamental_Wilson_2025/raw_data/gradient_flow/Lt32Ls16beta6.9mas-0.89FUN/topology/out/out_flow" 
file_out = "/home/fabian/Documents/Physics/Analysis/fundamental_Wilson_2025/raw_data/gradient_flow/Lt32Ls16beta6.9mas-0.89FUN/topology/out/out_flow_clean"     
clean_hirep_file(file_in,file_out)
