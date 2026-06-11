using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

dir = "/home/fabian/Documents/Physics/Data/DataMareNostrum/LLR_SU4/LLR_su4_7x40_84_Run_3"
newdir = "/home/fabian/Downloads/LLR_su4_7x40_84_Run_3_cleaned"
merge_llr(dir, newdir)

dir = "/home/fabian/Documents/Physics/Data/DataMareNostrum/LLR_SU4/LLR_su4_6x32_84_Run_2"
newdir = "/home/fabian/Downloads/LLR_su4_6x32_84_Run_2_cleaned"
merge_llr(dir, newdir)

dir = "/home/fabian/Documents/Physics/Data/DataMareNostrum/LLR_SU4/LLR_su4_5x32_84_Run_1"
newdir = "/home/fabian/Downloads/LLR_su4_5x32_84_Run_1_cleaned"
merge_llr(dir, newdir)