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
function assert_llr_files(file)
    start, finish, nlines = llr_start_and_end(file)
    @assert first(start)  == 1
    @assert last(finish)  == nlines
    @assert length(start) == length(finish)
    for i in 1:length(start)-1
        @assert  start[i+1] - 1 == finish[i]
    end
end
function find_malformed_files_in_dir(dir)
    paths = AbstractString[]
    for (root,dirs,files) in walkdir(dir)
        if "out_0" ∈ files
            file = joinpath(root,"out_0")
            healthy = check_llr_files(file)
            if !healthy
                push!(paths,file)
            end
        end
    end
    return paths
end

testfile = "/home/fabian/Documents/Physics/Data/DataCSD/CSD3/LLR_6x72_76/9/Rep_9/out_0"
testdir = "/home/fabian/Documents/Physics/Data/DataCSD/CSD3/"

malformed_dirs = find_malformed_files_in_dir(testdir)
start, finish, nlines = llr_start_and_end(malformed_dirs[1])

function healthy_ranges(start, finish, nlines)

end


#start, finish, nlines = llr_start_and_end(testfile)
#assert_llr_files(testfile)
#check_llr_files(testfile)