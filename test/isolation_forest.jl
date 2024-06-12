using Test
using ModalIsolationForests
using MLJBase
using StatsBase
using Plots

X..., y = MLJBase.load_iris()
# X = PropositionalLogiset(X)
X = hcat(collect(X)...)
X = cat(X, rand(4, 4), [5000 5000 5000 5000], dims=1)
sample_size = floor(Int, size(X, 1) * 0.7)

isolationforest = @test_nowarn ModalIsolationForests.build_mif_forest(X, 20, 3, sample_size)
scores = detect_mif_anomalies(isolationforest, X, sample_size)
histogram(scores)