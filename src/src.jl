
function hirep_start_and_end(file)
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
function hirep_checkpoints(file,pattern)
    checkpoint  = Int[]
    for (i,line) in enumerate(eachline(file))
        if occursin(pattern,line)
            push!(checkpoint,i)
        end
    end
    return checkpoint
end
function check_hirep_file(file)
    start, finish, nlines = hirep_start_and_end(file)
    check_hirep_file(start, finish, nlines)
end
function check_hirep_file(start, finish, nlines)
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
# Determine all ranges that are not deemed healthy
# The idea is to provide an optional kwarg that can identify checkpoints in the problemetic ranges.
# We can then include the problematic ranges up to that checkpoint and only discard the final part.
function split_problematic_ranges(ranges,start)
    split_ranges = UnitRange[]
    for r in ranges
        inds = findall(x -> x in r, start)
        ind0 = first(r)
        for s in start[inds]
            if s <= ind0
                continue
            else
                push!(split_ranges,ind0:s-1)
                ind0 = s
            end
        end
        # now deal with the last range
        push!(split_ranges,ind0:last(r))
    end
    return split_ranges
end
function find_problematic_ranges(file)
    start, finish, nlines = hirep_start_and_end(file)
    ranges = find_healthy_ranges(start, finish)
    if isempty(ranges)
        return [1:nlines]
    end
    problematic_ranges=UnitRange[]
    if first(ranges[1]) != 1
        push!(problematic_ranges,1:first(ranges[1])-1)
    end
    for i in eachindex(ranges[1:end-1])
        if last(ranges[i]) + 1 == first(ranges[i+1])
            continue
        else
            push!(problematic_ranges, last(ranges[i])+1:first(ranges[i+1])-1)
        end
    end
    if last(ranges[end]) != nlines
        push!(problematic_ranges,last(ranges[end])+1:nlines)
    end
    # Up to now we have only identified the ranges based
    # It could still be the case that there are actually mor
    split = split_problematic_ranges(problematic_ranges,start)
    return split
end
function checkpointed_problematic_ranges(problematic_ranges, checkpoints)
    checkpointed_ranges = UnitRange[]
    for range in problematic_ranges
        ind = findlast(x -> x in range,checkpoints)
        if !isnothing(ind)
            push!(checkpointed_ranges,first(range):checkpoints[ind])
        end
    end
    return checkpointed_ranges
end
function write_healthy_ranges(newfile,file,ranges)
    lines_to_copy = sort(vcat(ranges...))
    isempty(lines_to_copy) && return
    next_line_ind = 1 
    io = open(newfile,"w")
    for (i,line) in enumerate(eachline(file))
        if i == lines_to_copy[next_line_ind]
           write(io,line,'\n')
           next_line_ind +=1
           next_line_ind > length(lines_to_copy) && break
        end
    end
    close(io)
end
function clean_hirep_file(file,newfile;checkpoint_pattern=nothing)
    start, finish, nlines = hirep_start_and_end(file)
    ranges = find_healthy_ranges(start, finish)
    if !isnothing(checkpoint_pattern)
        checkpoints = hirep_checkpoints(file,checkpoint_pattern)
        bad_ranges  = find_problematic_ranges(file)
        ckp_ranges  = checkpointed_problematic_ranges(bad_ranges, checkpoints)
        ranges = sort(vcat(ranges,ckp_ranges))
    end
    write_healthy_ranges(newfile,file,ranges)
end
function clean_llr_directory(dir,newdir;checkpoint_pattern=nothing,last_ranges=nothing, warn=true)
    paths_and_ranges = Dict()
    for (root,dirs,files) in walkdir(dir)
        if "out_0" ∈ files
            file = joinpath(root,"out_0")
            start, finish, nlines = hirep_start_and_end(file)
            healthy = check_hirep_file(start, finish, nlines)
            newfile = joinpath(newdir,relpath(file,dir))
            ispath(dirname(newfile)) || mkpath(dirname(newfile))
            if healthy
                cp(file,newfile)
            else
                ranges = find_healthy_ranges(start, finish)
                if !isnothing(checkpoint_pattern)
                    checkpoints = hirep_checkpoints(file,checkpoint_pattern)
                    bad_ranges  = find_problematic_ranges(file)
                    ckp_ranges  = checkpointed_problematic_ranges(bad_ranges, checkpoints)
                    ranges = sort(vcat(ranges,ckp_ranges))
                end
                if !isnothing(last_ranges)
                    ranges = ranges[end-last_ranges:end]
                end
                if warn 
                    @warn "file $file has sections that terminated prematurely" 
                end
                paths_and_ranges[file] = ranges
                write_healthy_ranges(newfile,file,ranges)
            end
        end
    end
    return paths_and_ranges
end