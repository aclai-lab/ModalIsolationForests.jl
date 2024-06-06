module ModalIsolationForest

export calculate_c, evaluate_formula

# Import functionalities
include("core.jl")

export MIFNode, MIFTree, build_mif_tree

include("isolation_tree.jl")

export MIFForest, build_mif_forest, detect_mif_anomalies, path_length

include("isolation_forest.jl")

# Export functionalities
end
