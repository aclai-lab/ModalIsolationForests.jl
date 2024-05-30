using SoleLogics

export calculate_c, generate_random_modal_formula, evaluate_formula

# Utility function to calculate c(n)
function calculate_c(n::Int)::Float64
    return 2 * (log(n - 1) + 0.5772156649) - (2 * (n - 1) / n)
end

# Utility function to generate random modal formulas
function generate_random_modal_formula()
    randformula()  # Function call from SoleLogics
end

# Utility function to evaluate modal formulas
function evaluate_formula(formula, data_point)
    interpret(formula, data_point)  # Example function call from SoleLogics
end