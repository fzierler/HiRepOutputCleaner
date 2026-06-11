using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

dir      = "/home/fabian/Documents/Physics/Data/DataDiaL/LLR_SU4/LLR_su4_5x32_96_Run_2/47"
newdir   = "/home/fabian/Downloads/LLR_su4_5x32_96_Run_2/47"
truncdir = "/home/fabian/Downloads/LLR_su4_5x32_96_Run_2/47"
clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing,extra_files=true, extra_pattern=r"(\.err|\.out)")
HiRepOutputCleaner.force_clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing)
truncate_llr_directory(newdir,truncdir,1,dry_run=false,extra_files=true, extra_pattern=r"(\.err|\.out)")