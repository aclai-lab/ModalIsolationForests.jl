using SoleLogics

export calculate_c, generate_random_modal_formula, evaluate_formula

# Utility function to calculate c(n)
calculate_c(n::Int)::Float64 = 2 * (log(n - 1) + 0.5772156649) - (2 * (n - 1) / n)

# Utility function to generate random modal formulas
generate_random_modal_formula() = randformula()  # Function call from SoleLogics

# Utility function to evaluate modal formulas
evaluate_formula(formula, data_point) = interpret(formula, data_point)  # Function call from SoleLogics