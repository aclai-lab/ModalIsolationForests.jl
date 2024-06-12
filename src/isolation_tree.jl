using Sole
using Random
using Distributions

mutable struct MIFNode
    split_formula::Union{Formula,Nothing}
    left::Union{MIFNode, Nothing}
    right::Union{MIFNode, Nothing}
    size::Int  # Keep track of the size of the sample at this node
end

mutable struct MIFTree
    root::MIFNode
end

function _broadc(fun, table)
    vec(fun.(Tables.columns(table)))
end

function _broadc(fun, table::NamedTuple)
    vec(fun.(collect(Tables.columns(table))))
end

@inline function random_oblique_conditions(
    rng::AbstractRNG,
    numconditions::Integer,
    X::PropositionalLogiset,
    max_obliqueness_extension::Integer,
)
    nvariables = SoleData.nvariables(X)
    mins = _broadc(minimum, gettable(X))
    maxs = _broadc(maximum, gettable(X))
    features = SoleData.VariableValue.(1:nvariables)

    u = randn(rng, nvariables, numconditions)
    b = (rand(rng, nvariables, numconditions) .* (maxs .- mins)) .+ mins
    obliqueness_extension = rand(rng, 1:max_obliqueness_extension)
    conds = [begin
        null_idxs = randperm(rng, nvariables)[1:(nvariables-obliqueness_extension)]
        u[null_idxs, i_cond] .= 0
        SoleData.ObliqueScalarCondition(features, b[:,i_cond], u[:,i_cond], <)
    end for i_cond in 1:numconditions]
    return conds
end

@inline function random_oblique_condition(
    rng::AbstractRNG,
    X::PropositionalLogiset,
    obliqueness_extension::Integer,
)
    nvariables = SoleData.nvariables(X)
    mins = _broadc(minimum, gettable(X))
    maxs = _broadc(maximum, gettable(X))
    features = SoleData.VariableValue.(1:nvariables)

    u = randn(rng, nvariables)
    b = (rand(rng, nvariables) .* (maxs .- mins)) .+ mins
    null_idxs = randperm(rng, nvariables)[1:(nvariables-obliqueness_extension)]
    u[null_idxs] .= 0
    cond = SoleData.ObliqueScalarCondition(features, b, u, <)
    return cond
end

function build_isolation_tree(
    X::PropositionalLogiset,
    current_height::Int = 0;
    max_height::Union{Nothing,Int} = nothing,
    formula_max_height = 0,
    obliqueness_extension = 3,
    rng::AbstractRNG = Random.GLOBAL_RNG,
    operators = [∨, ∧, ¬],
)::MIFNode
    if (!isnothing(max_height) && current_height >= max_height) || ninstances(X) <= 1
        return MIFNode(nothing, nothing, nothing, ninstances(X))  # Leaf node
    end

    kwargs = (;
        max_height = max_height,
        formula_max_height = formula_max_height,
        obliqueness_extension = obliqueness_extension,
        rng = rng,
        operators = operators,
    )
    
    split_formula = begin
        if formula_max_height == 0
            cond = random_oblique_condition(rng, X, obliqueness_extension)
            Atom(cond)
        else
            # conds = random_oblique_conditions(rng, numconditions, X, obliqueness_extension)
            # Sole.randformula(rng, formula_max_height, Atom.(conds), operators)
            Sole.randformula(rng, formula_max_height, Atom[], operators; atompicker = (rng, alphabet)->Atom(random_oblique_condition(rng, X, obliqueness_extension)))
        end
    end
    left_indices = SoleLogics.check(split_formula, X)

    right_indices = (~).(left_indices)

    left_child = build_isolation_tree(slicedataset(X, left_indices; allow_no_instances = true), current_height + 1; kwargs...)
    right_child = build_isolation_tree(slicedataset(X, right_indices; allow_no_instances = true), current_height + 1; kwargs...)

    return MIFNode(split_formula, left_child, right_child, ninstances(X))
end
