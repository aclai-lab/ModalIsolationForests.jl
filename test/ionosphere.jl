using Test
using ModalIsolationForests
using MLJBase
using StatsBase
using Plots
using Random


include("mydatasets.jl")

X, y = mydatasets[:I]
y = (y .== 1)
# y = true .- y # invert

# isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; n_trees=100, max_height = nothing, obliqueness_extension=1, partial_sampling=128, formula_max_height=0);
# isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; rng = MersenneTwister(1), n_trees=10, max_height=127 - 1, obliqueness_extension=1, partial_sampling=128, formula_max_height=0);
isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; rng = MersenneTwister(1), n_trees=100, max_height=127 - 1, obliqueness_extension=1, partial_sampling=128, formula_max_height=0);
# isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; n_trees=10, max_height=127 - 1, obliqueness_extension=10, partial_sampling=128, formula_max_height=0);
scores = @test_nowarn detect_anomalies(isolationforest, X)
histogram(scores)

countmap(y)
is_anomaly = (y .== 0)

@test calculate_auc(scores, is_anomaly) > 0.7

# using BenchmarkTools
# @btime MLJBase.auc(map(s -> MLJBase.UnivariateFinite([true, false], [s, 1 - s]), scores), is_anomaly)
# @btime calculate_auc(scores, is_anomaly)

# anomaly_scores = collect(zip(scores, is_anomaly))


# nanomalies = (sum(y .== 0))
# nnormals = (sum(y .== 1))

# function calculate_auc(anomaly_scores::Array{Tuple{Float64,Bool}}, na::Int, nn::Int)
#   # Step 1: Sort anomaly scores in descending order
#   sorted_scores = sort(anomaly_scores, by=x -> x[1], rev=true)

#   # Step 2: Calculate the rankings of the true anomalies
#   S = 0.0
#   rank = 1
#   for (score, is_anomaly) in sorted_scores
#     if is_anomaly
#       S += rank
#     end
#     rank += 1
#   end

#   # Step 3: Calculate AUC using the formula
#   auc = (S - (na^2 + na) / 2) / (na * nn)

#   return auc
# end


# _auc = calculate_auc(anomaly_scores, nanomalies, nnormals)
# println("AUC: ", _auc)

# p = sortperm(scores, rev=true)
# sorted_y = y[p]
# rankings = invperm(p)
# # S = sum(rankings[p][sorted_y .== 0])
# S = sum(rankings[y.==0])

# AUC = (S - (nanomalies^2 + nanomalies) / 2) / (nanomalies * nnormals)
