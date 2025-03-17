using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

file_in  = "/home/fabian/Documents/Physics/Data/Paul/out_spectrum_smeared_Lt32Ls24beta6.9mas-0.924FUN" 
file_out = "/home/fabian/Documents/Physics/Data/Paul/out_spectrum_smeared_Lt32Ls24beta6.9mas-0.924FUN_cleaned"     
clean_hirep_file(file_in,file_out)
