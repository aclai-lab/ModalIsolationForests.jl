using SoleLogics
using SoleLogics: AbstractInterpretation
using Random


mutable struct MIFForest
    trees::Vector{ModalIsolationForest.MIFTree}
end

function build_mif_forest(X::PropositionalLogiset, num_trees::Int, max_height::Int, sample_size::Int)::MIFForest
    trees = [ModalIsolationForest.MIFTree(build_mif_tree(slicedataset(X, rand(1:ninstances(X), sample_size)), max_height)) for _ in 1:num_trees]
    return MIFForest(trees)
end

function detect_mif_anomalies(forest::MIFForest, X::PropositionalLogiset, sample_size::Int)::Vector{Float64}
    c_n = calculate_c(sample_size)  # Calculate c(sample_size) once for the dataset
    scores = [begin
        avg_path_length = mean([path_length(tree.root, inst) for tree in forest.trees])
        2^(-avg_path_length / c_n)  # Calculate the anomaly score
    end for inst in eachinstance(X)]
    return scores
end

function path_length(node::ModalIsolationForest.MIFNode, point::AbstractInterpretation, current_length::Int = 0)::Float64
if node.left == nothing || node.right == nothing
        return current_length + calculate_c(node.size)  # Correctly use the sample size at the node
    end
    if SoleLogics.check(node.split_formula, point)
        return path_length(node.left, point, current_length + 1)
    else
        return path_length(node.right, point, current_length + 1)
    end
end

function build_mif_forest(X::Matrix{Float64}, args...; kwargs...)
    build_mif_forest(PropositionalLogiset(Tables.table(X)), args...; kwargs...)
end

function detect_mif_anomalies(forest::MIFForest, X::Matrix{Float64}, args...; kwargs...)
    detect_mif_anomalies(forest, PropositionalLogiset(Tables.table(X)), args...; kwargs...)
end
