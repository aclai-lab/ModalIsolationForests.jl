
# Utility function to calculate c(n)
function calculate_c(n::Int)::Float64
    if n > 2
        c_n = 2 * log(n - 1) + Base.MathConstants.eulergamma - 2 * (n - 1) / n
    elseif n == 1
        c_n = 1
    else # TODO: is this really necessary?
        c_n = 0
    end

    return c_n
end
