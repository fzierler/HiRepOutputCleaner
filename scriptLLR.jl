using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

dir    = "/home/fabian/Documents/Physics/Data/DataCSD/CSD3/"
newdir = "/home/fabian/Downloads/LLRout" 
clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing)