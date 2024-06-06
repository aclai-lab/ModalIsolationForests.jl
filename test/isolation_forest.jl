using Test
using ModalIsolationForest
using MLJBase

X..., y = MLJBase.load_iris()
# X = PropositionalLogiset(X)
X = hcat(collect(X)...)
sample_size = floor(Int, size(X, 1) * 0.7)
@test_nowarn isolation_tree = ModalIsolationForest.build_mif_forest(X, 20, 3, sample_size)


isolation_tree

build_mif_forest(data::Matrix{Float64}, num_trees::Int, max_height::Int, sample_size::Int)::MIFForest
detect_mif_anomalies(forest::MIFForest, data::Matrix{Float64}, sample_size::Int)::Vector{Float64}