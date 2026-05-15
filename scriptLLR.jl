using Pkg; Pkg.activate(".")
using HiRepOutputCleaner

function truncate_llr_directory(dir,newdir,runs;dry_run=false)    
    for (root,dirs,files) in walkdir(dir)
        if "out_0" ∈ files

            file = joinpath(root,"out_0")
            start, finish, nlines = HiRepOutputCleaner.hirep_start_and_end(file)
            healthy = HiRepOutputCleaner.check_hirep_file(start, finish, nlines)
            ranges = HiRepOutputCleaner.find_healthy_ranges(start[1:runs], finish[1:runs]) 

            @assert healthy
            @show file
            @show length(start), length(finish), length(ranges)

            if !dry_run
                newfile = joinpath(newdir,relpath(file,dir))
                ispath(dirname(newfile)) || mkpath(dirname(newfile))
                HiRepOutputCleaner.write_healthy_ranges(newfile,file,ranges)
            end
        end
    end
end

dir      = "/home/fabian/Documents/Physics/Data/DataDiaL/LLR_SU4/LLR_su4_5x32_96_Run_2/47"
newdir   = "/home/fabian/Downloads/LLR_su4_5x32_96_Run_2/47"
truncdir = "/home/fabian/Downloads/LLR_su4_5x32_96_Run_2/47"
clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing)
HiRepOutputCleaner.force_clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing)
truncate_llr_directory(newdir,truncdir,1,dry_run=false)