using Random

mutable struct MIFForest
    trees::Vector{ModalIsolationForest.MIFTree}
end

function build_mif_forest(data::Matrix{Float64}, num_trees::Int, max_height::Int, sample_size::Int)::MIFForest
    trees = [ModalIsolationForest.MIFTree(build_mif_tree(sample(data, sample_size, replace=false), 0, max_height)) for _ in 1:num_trees]
    MIFForest(trees)
end

function detect_mif_anomalies(forest::MIFForest, data::Matrix{Float64}, sample_size::Int)::Vector{Float64}
    scores = zeros(size(data, 1))
    c_n = calculate_c(sample_size)  # Calculate c(sample_size) once for the dataset
    for i in 1:size(data, 1)
        avg_path_length = mean([path_length(tree.root, data[i, :]) for tree in forest.trees])
        scores[i] = 2^(-avg_path_length / c_n)  # Calculate the anomaly score
    end
    scores
end

function path_length(node::ModalIsolationForest.MIFNode, point::Vector{Float64}, current_length::Int = 0)::Float64
    if node.left == nothing || node.right == nothing
        return current_length + calculate_c(node.size)  # Correctly use the sample size at the node
    end
    if evaluate_formula(node.split_formula, point)
        return path_length(node.left, point, current_length + 1)
    else
        return path_length(node.right, point, current_length + 1)
    end
end

export MIFForest, build_mif_forest, detect_mif_anomalies, path_length
