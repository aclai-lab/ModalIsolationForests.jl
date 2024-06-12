using Test
using ModalIsolationForests
using MLJBase
using StatsBase
using Plots
using Random

X..., y = MLJBase.load_iris()
# X = PropositionalLogiset(X)
X = hcat(collect(X)...)
X = cat(X, rand(4, 4), [5000 5000 5000 5000], dims=1)

is_anomaly = fill(false, size(X, 1))
is_anomaly[end-5:end] .= true

isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; n_trees=100, max_height=3, partial_sampling=0.2, formula_max_height = 0);
scores = @test_nowarn detect_anomalies(isolationforest, X)
histogram(scores)

calculate_auc(scores, is_anomaly)

isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; n_trees=20, max_height=3, partial_sampling=0.7, formula_max_height = 1);
scores = @test_nowarn detect_anomalies(isolationforest, X)
histogram(scores)


isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; n_trees=20, max_height=10, partial_sampling=0.7, formula_max_height=2);
scores = @test_nowarn detect_anomalies(isolationforest, X)
histogram(scores)
