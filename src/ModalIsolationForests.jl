module ModalIsolationForests

using Tables

using SoleLogics
using SoleLogics: AbstractInterpretation

using SoleData
using SoleData: AbstractLogiset, PropositionalLogiset, gettable

using LinearAlgebra


export calculate_c

# Import functionalities
include("core.jl")

export MIFNode, MIFTree, build_isolation_tree

include("isolation_tree.jl")

export MIFForest, build_isolation_forest, detect_anomalies, calculate_auc

include("isolation_forest.jl")

# Export functionalities
end
