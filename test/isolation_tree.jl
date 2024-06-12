using Test
using ModalIsolationForests
using MLJBase

X..., y = MLJBase.load_iris()
# X = PropositionalLogiset(X)
X = hcat(collect(X)...)
@test_nowarn isolation_tree = ModalIsolationForests.build_mif_tree(X, 3)
