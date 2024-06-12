using Test
using CategoricalArrays
using Tables
using Sole
using ModalIsolationForests
using MLJBase
using StatsBase
using Plots
using Random
using OpenML


X = OpenML.load(5);

is_anomaly = map(in(["03", "04", "05", "07", "274", "08", "09", "14", "15"]), X[:class])


newcolnames = filter((k) -> !(k in [Tables.columnnames(X)[11:15]..., :class]), Tables.columnnames(X))

X = (NamedTuple([c => begin
  col = Tables.getcolumn(X, c)
  if col isa CategoricalArrays.CategoricalVector
    parse.(Float64, String.(col))
  else
    col
  end
end for c in newcolnames]))

# categorical_columns = (<:).(eltype.(collect(Tables.columns(X))), CategoricalArrays.CategoricalValue)
# [X[c] for c in keys(X)[categorical_columns]]

eltype.(collect(Tables.columns(X)))

isolationforest = @test_nowarn ModalIsolationForests.build_isolation_forest(X; n_trees=10, max_height=127 - 1, obliqueness_extension=1, partial_sampling=128, formula_max_height=0);
scores = @test_nowarn detect_anomalies(isolationforest, X)
histogram(scores)


countmap(is_anomaly)
calculate_auc(scores, is_anomaly)

# anomaly_scores = collect(zip(scores, is_anomaly))


# nanomalies = sum(is_anomaly)
# nnormals = sum((!).(is_anomaly))

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
