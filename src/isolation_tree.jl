using Random
using Distributions

mutable struct MIFNode
    split_formula::Union{Formula,Nothing}
    left::Union{MIFNode, Nothing}
    right::Union{MIFNode, Nothing}
    size::Int  # Keep track of the size of the sample at this node
end

mutable struct MIFTree
    root::MIFNode
end

function _build_mif_tree(
    X::PropositionalLogiset,
    current_height::Int,
    max_height::Int;
    formula_max_height = 0,
    obliqueness_extension = 3,
    rng::AbstractRNG = Random.MersenneTwister(1),
    operators = [∨, ∧, ¬],
)::MIFNode
    if current_height >= max_height || ninstances(X) <= 1
        return MIFNode(nothing, nothing, nothing, ninstances(X))  # Leaf node
    end
    
    split_formula = begin
        if formula_max_height == 0

            nvariables = SoleData.nvariables(X)
            mins = vec(minimum.(Tables.columns(gettable(X))))
            maxs = vec(maximum.(Tables.columns(gettable(X))))
            null_idxs = randperm(rng, nvariables)[1:(nvariables-obliqueness_extension-1)]
            n = randn(nvariables)
            n[null_idxs] .= 0
            p = (rand(nvariables) .* (maxs.-mins)) .+ mins
            
            features = SoleData.VariableValue.(1:nvariables)
            Atom(SoleData.ObliqueScalarCondition(features, p, n, <))
        else
            error("TODO implement.")
            # SoleLogics.randformula(rng, formula_max_height, , operators)  # Use existing utilities
        end
    end
    left_indices = SoleLogics.check(split_formula, X)

    right_indices = (~).(left_indices)

    left_child = _build_mif_tree(slicedataset(X, left_indices; allow_no_instances = true), current_height + 1, max_height)
    right_child = _build_mif_tree(slicedataset(X, right_indices; allow_no_instances = true), current_height + 1, max_height)

    return MIFNode(split_formula, left_child, right_child, ninstances(X))
end

function build_mif_tree(X::Matrix{Float64}, max_height::Int)::MIFNode
    return _build_mif_tree(PropositionalLogiset(Tables.table(X)), 0, max_height)
end
function build_mif_tree(X::PropositionalLogiset, max_height::Int)::MIFNode
    return _build_mif_tree(X, 0, max_height)
end
