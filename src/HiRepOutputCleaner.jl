module HiRepOutputCleaner

include("src.jl")
export clean_hirep_file, clean_llr_directory, truncate_llr_directory
include("merge_llr.jl")
export merge_llr

end # module HiRepOutputCleaner
