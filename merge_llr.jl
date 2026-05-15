function check_slurm_files(standard_out_files)
    file_sizes = filesize.(standard_out_files)
    # make sure that we only have at most one file for 
    # 1) thermalisation  2) newton-raphson  3) robbins-monro   4) fixed a
    @assert count(contains("therm"),standard_out_files) <= 1 
    @assert count(contains("newton_raphson"),standard_out_files) <= 1 
    @assert count(contains("robbins_monro"),standard_out_files) <= 1 
    @assert count(contains("fixed_a"),standard_out_files) <= 1 
    # if we have data, then make sure that it only affects one file 
    @assert count(x->x>0, file_sizes) == 1
end
# Utility for counting the number of runs in a given file
# In this code, we want to only consider cases where we have exactly one run
function count_runs(file)
    c = 0
    for l in eachline(file)
        if startswith(l, "[SYSTEM][0]Gauge group:")
            c += 1
        end
    end
    return c
end
# identify the replica based on the contents of the files
# this function additionally checks that all replica_ids 
# present in this file are identical 
function replica_id_from_file(file)
    replica_ids = String[]
    rx = r"\[SYSTEM\]\[0\]\[RepID: (?<replica>[0-9]+)\]"
    for l in eachline(file)
        if startswith(l,rx)
            m = match(rx,l)
            push!(replica_ids,m["replica"]) 
        end
    end
    # if there is nothing to be found return nothing
    # otherwise assert that there the replica id always matches
    isempty(replica_ids) && return nothing
    return only(unique(replica_ids))
end

function main(dir,newdir)

    # find all directories in overarching directory
    folders = filter(isdir,readdir(dir,join=true))
    # filter out only directories of the repeats 
    repeats = filter(f -> startswith(basename(f),r"[0-9]+"),folders)

    for repeat in repeats

        # find the files that contain the stray data that is not saved 
        # in the correct output files.
        standard_out_files = filter(endswith(".out"),readdir(repeat,join=true))
        file_sizes = filesize.(standard_out_files)

        # make sure that those files are non-empty, except for a single one 
        # make also sure that those files only contain data for one replica
        if all(iszero,file_sizes)
            continue
        end

        # make sure that we only have one file to deal with
        # and that we do not have duplicate files
        check_slurm_files(standard_out_files)

        # identify the only file that needs to be appended to an existing repeat
        file2append = only(filter(f->filesize(f)>0, standard_out_files))
        
        # make sure that the file contains only data from exactly on run
        # then find the corresponding replica from the file
        @assert count_runs(file2append) == 1
        missing_replica = replica_id_from_file(file2append)
        @show missing_replica

        # indentify all replicas that are present
        is_replica(dir) = isdir(dir) && endswith(dir,r"Rep_[0-9]+")
        replicas = filter(is_replica ,readdir(repeat,join=true))
        replica_files = joinpath.(replicas,Ref("out_0"))

        # check that all files are present and that they match 
        @assert all(isfile,replica_files)

        # assert that the identified replica has one fewer run than all other
        # replicas. this essentially is an idenpendent check that we have 
        # identified the correct replica.        
        replica_run_counts = count_runs.(replica_files)
        nruns = maximum(replica_run_counts)
        replica_index = only(findall(isequal(nruns-1),replica_run_counts))
        missing_replica_file = replica_files[replica_index]
        missing_replica_id_alt = match(r"Rep_(?<replica>[0-9]+)",missing_replica_file)["replica"] 
        @assert missing_replica_id_alt == missing_replica

        # make a copy of the old data which will be used morked on
        cp(joinpath(dir,repeat),joinpath(newdir,repeat))

        # Append the file 
        io = open(missing_replica_file,"a")
        for l in eachline(file2append)
            write(io,l)
        end
        close(io)
        rm(file2append)
        touch(file2append)
    end
end

dir = "/home/fabian/Documents/Physics/Data/DataMareNostrum/LLR_SU4/LLR_su4_7x40_84_Run_3"
newdir = "/home/fabian/Downloads/LLR_su4_7x40_84_Run_3_cleaned"
main(dir, newdir)