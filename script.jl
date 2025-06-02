using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

file_in  = "/home/fabian/Documents/Physics/Data/DataVSC/measurements/runsSp4/Lt36Ls36beta7.05m1-0.867m2-0.867/out/out_scattering_I1_run1" 
file_out = "/home/fabian/Documents/Physics/Data/DataVSC/measurements/runsSp4/Lt36Ls36beta7.05m1-0.867m2-0.867/out/out_scattering_I1_run1_cleaned"     
clean_hirep_file(file_in,file_out;checkpoint_pattern="analysed")
