using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

dir    = "/home/fabian/Documents/Physics/Data/DataLLR/llr_sp4"
newdir = "/home/fabian/Documents/Physics/Data/DataLLR/llr_sp4_cleaned_v1" 
clean_llr_directory(dir,newdir;checkpoint_pattern="")
