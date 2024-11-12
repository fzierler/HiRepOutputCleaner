function llr_start_and_end(file)
    start  = Int[]
    finish = Int[]
    nlines = 0
    for (i,line) in enumerate(eachline(file))
        if startswith(line,"[SYSTEM][0]Gauge group:")
            push!(start,i)
        end
        if startswith(line,"[SYSTEM][0]Process finalized.")
            push!(finish,i)            
        end
        nlines += 1
    end
    return start, finish, nlines
end
function check_llr_files(file)
    start, finish, nlines = llr_start_and_end(file)
    check_llr_files(start, finish, nlines)
end
function check_llr_files(start, finish, nlines)
    isempty(start) && return false
    isempty(finish) && return false
    first(start)  == 1 || return false
    last(finish)  == nlines || return false
    length(start) == length(finish) || return false
    for i in 1:length(start)-1
        start[i+1] - 1 == finish[i] || return false
    end
    return true
end
function find_healthy_ranges(start, finish)
    # start with the first start of a run
    ind_s0 = 1
    ranges = UnitRange[]
    while ind_s0 in eachindex(start)
        s0 = start[ind_s0]
        # find next entry in either start or finishes
        ind_s = findfirst(x->x>s0,start)
        ind_f = findfirst(x->x>s0,finish)
        # if we find no further end of input files, then we are done 
        isnothing(ind_f) && return ranges
        # if the next match is one that finishes then we probably have identified a healthy section of the output file
        # (I am mostly assuming that we don't have issues where two runs have been writing to the output file simultaneously)
        if isnothing(ind_s) || finish[ind_f] < start[ind_s]
            f1 = finish[ind_f] 
            push!(ranges,s0:f1)
        end
        ind_s0 = ind_s
    end
    return ranges
end
function find_malformed_files_and_healthy_ranges(dir,newdir)
    paths_and_ranges = Dict()
    for (root,dirs,files) in walkdir(dir)
        if "out_0" ∈ files
            file = joinpath(root,"out_0")
            start, finish, nlines = llr_start_and_end(file)
            healthy = check_llr_files(start, finish, nlines)
            newfile = joinpath(newdir,relpath(file,dir))
            ispath(dirname(newfile)) || mkpath(dirname(newfile))
            if healthy
                cp(file,newfile)
            else
                ranges = find_healthy_ranges(start, finish)
                paths_and_ranges[file] = ranges
                io = open(newfile,"w")
                old_file = readlines(file)
                for r in ranges
                    for l in r
                       write(io,old_file[l])
                    end
                end
                close(io)
            end
        end
    end
    return paths_and_ranges
end

testdir = "/home/fabian/Documents/Physics/Data/DataCSD/Archives/full/"
newdir  = "/home/fabian/Documents/Physics/Data/DataCSD/Archives/cleaned/"
dict = find_malformed_files_and_healthy_ranges(testdir,newdir)
