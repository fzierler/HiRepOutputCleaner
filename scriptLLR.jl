using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

dir    = "/home/fabian/Documents/Physics/Data/DataSunbird/Sunbird/LLR/LLR_5x80_64/0/"
newdir = "/home/fabian/Downloads/LLR_5x80_64/" 
#clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing)
HiRepOutputCleaner.force_clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing)