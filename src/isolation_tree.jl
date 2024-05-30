mutable struct MIFNode
    split_formula::Formula
    left::Union{MIFNode, Nothing}
    right::Union{MIFNode, Nothing}
    size::Int  # Keep track of the size of the sample at this node
end

mutable struct MIFTree
    root::MIFNode
end

function build_mif_tree(data::Matrix{Float64}, current_height::Int, max_height::Int)::MIFNode
    if current_height >= max_height || size(data, 1) <= 1
        return MIFNode(Formula(), nothing, nothing, size(data, 1))  # Leaf node
    end
    split_formula = ModalIsolationForest.generate_random_modal_formula()  # Use existing utilities

    left_indices = data .|> (x -> ModalIsolationForest.evaluate_formula(split_formula, x))
    right_indices = .~left_indices

    left_child = build_mif_tree(data[left_indices, :], current_height + 1, max_height)
    right_child = build_mif_tree(data[right_indices, :], current_height + 1, max_height)

    MIFNode(split_formula, left_child, right_child, size(data, 1))
end

export MIFNode, MIFTree, build_mif_tree