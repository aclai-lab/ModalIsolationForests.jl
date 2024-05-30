using Test
using ModalIsolationForest

@testset "Core Tests" begin
    @test ModalIsolationForest.calculate_c(10) ≈ 3.7488804844724397  # Example test for c(n) calculation
end