using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

names = [
    "LLR_su4_7x40_84_Run_3",
    "LLR_su4_6x32_84_Run_2",
    "LLR_su4_5x32_84_Run_1",
]

for name in names
    dir = "/home/fabian/Documents/Physics/Data/DataMareNostrum/LLR_SU4/$(name)"
    cleandir = "/home/fabian/Downloads/$(name)_cleaned"
    mergedir = "/home/fabian/Downloads/$(name)_merged"
    clean_llr_directory(dir,cleandir;checkpoint_pattern=nothing,last_ranges=nothing,warn=false,extra_files=true, extra_pattern=r"(\.err|\.out)")
    merge_llr(cleandir, mergedir)
end