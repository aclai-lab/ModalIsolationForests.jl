using Test
using ModalIsolationForest

function run_tests(list)
  println("\n" * ("#"^50))
  for test in list
    println("TEST: $test")
    @time include(test)
  end
end

println("Julia version: ", VERSION)

test_suites = [
  ("Core", ["core.jl",]),
  ("Isolation Tree", ["isolation_tree.jl",]),
  ("Isolation Forest", ["isolation_forest.jl",]),
]

@testset "SoleLogics.jl" begin
  for ts in eachindex(test_suites)
    name = test_suites[ts][1]
    list = test_suites[ts][2]
    let
      @testset "$name" begin
        run_tests(list)
      end
    end
  end
  println()
end
