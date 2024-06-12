
# Utility function to calculate c(n)
function calculate_c(n::Int)::Float64
    if n > 2
        c_n = 2 * (log(n - 1) + Base.MathConstants.eulergamma) - 2 * (n - 1) / n
    elseif n == 2
        c_n = 1
    else
        c_n = 0
    end
    return c_n
end


function calculate_auc(scores::AbstractVector{<:Float64}, is_anomaly::AbstractVector{Bool})
    p = sortperm(scores, rev=false)
    # sorted_y = y[p]
    rankings = invperm(p)
    # S = sum(rankings[p][sorted_y .== 0])
    S = sum(rankings[is_anomaly])
    nanomalies = sum(is_anomaly)
    nnormals = sum((!).(is_anomaly))
    AUC = (S - (nanomalies^2 + nanomalies) / 2) / (nanomalies * nnormals)
end

# # Utility function to calculate c(n)
# function calculate_c(n::Int)::Float64
#     if n > 2
#         c_n = 2 * log(n - 1) + Base.MathConstants.eulergamma - 2 * (n - 1) / n
#     elseif n == 1
#         c_n = 1
#     else # TODO: is this really necessary?
#         c_n = 0
#     end

#     return c_n
# end

# import numpy as np
# calculate_c = lambda n : 2.0*(np.log(n-1)+0.5772156649) - (2.0*(n-1.)/(n*1.0))
# list(map(calculate_c, range(0, 5)))