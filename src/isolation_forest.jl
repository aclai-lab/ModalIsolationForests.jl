using SoleBase
using SoleLogics
using SoleLogics: AbstractInterpretation
using Random


mutable struct MIFForest
    trees::Vector{ModalIsolationForests.MIFTree}
    sample_size::Int
end

function build_isolation_forest(
    X::PropositionalLogiset;
    n_trees::Int,
    partial_sampling::Union{Int,Float64},
    rng::AbstractRNG = Random.GLOBAL_RNG,
    tree_kwargs...,
)::MIFForest
    sample_size = partial_sampling isa Int ? partial_sampling : floor(Int, ninstances(X) * partial_sampling)
    trees = Vector{ModalIsolationForests.MIFTree}(undef, n_trees)
    rngs = [SoleBase.spawn(rng) for i_tree in 1:n_trees]
    Threads.@threads for i_tree in 1:n_trees
        subX = slicedataset(X, rand(rng, 1:ninstances(X), sample_size); return_view=true)
        this_rng = rngs[i_tree]
        trees[i_tree] = ModalIsolationForests.MIFTree(build_isolation_tree(subX; rng = this_rng, tree_kwargs...))
    end
    return MIFForest(trees, sample_size)
end

function detect_anomalies(forest::MIFForest, X::PropositionalLogiset)::Vector{Float64}
    c_n = calculate_c(forest.sample_size)  # Calculate c(sample_size) once for the dataset
    scores = [begin
        avg_path_length = mean([pathlength(tree.root, inst) for tree in forest.trees])
        2^(-avg_path_length / c_n)  # Calculate the anomaly score
    end for inst in eachinstance(X)]
    return scores
end

function pathlength(node::ModalIsolationForests.MIFNode, inst::AbstractInterpretation, current_length::Int = 0)::Float64
    if node.left == nothing || node.right == nothing
        return current_length + calculate_c(node.size)  # Correctly use the sample size at the node
    end
    if SoleLogics.check(node.split_formula, inst)
        return pathlength(node.left, inst, current_length + 1)
    else
        return pathlength(node.right, inst, current_length + 1)
    end
end

function build_isolation_tree(X, args...; kwargs...)::MIFNode
    if X isa AbstractMatrix
        X = Tables.table(X)
    end
    @assert Tables.istable(X) "Expected table (see Tables), but $(typeof(X)) " *
        "was provided."
    return build_isolation_tree(PropositionalLogiset(X), args...; kwargs...)
end
function build_isolation_forest(X, args...; kwargs...)
    if X isa AbstractMatrix
        X = Tables.table(X)
    end
    @assert Tables.istable(X) "Expected table (see Tables), but $(typeof(X)) " *
        "was provided."
    build_isolation_forest(PropositionalLogiset(X), args...; kwargs...)
end

function detect_anomalies(forest::MIFForest, X, args...; kwargs...)
    if X isa AbstractMatrix
        X = Tables.table(X)
    end
    @assert Tables.istable(X) "Expected table (see Tables), but $(typeof(X)) " *
                        "was provided."
    detect_anomalies(forest, PropositionalLogiset(X), args...; kwargs...)
end
