module HiRepOutputCleaner

include("src.jl")
export clean_llr_directory, clean_hirep_file
include("merge_llr.jl")
export merge_llr

end # module HiRepOutputCleaner
