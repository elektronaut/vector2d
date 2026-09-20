# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "matrix"
require "vector2d"

# Times Vector2d against the standard library Vector, one operation at
# a time, and prints a table of the results.
#
#   bundle exec rake benchmark
#   ITERATIONS=5000000 REPETITIONS=3 bundle exec ruby \
#     benchmark/vector_comparison.rb
#
module VectorComparison
  ITERATIONS = Integer(ENV.fetch("ITERATIONS", "1000000"))
  REPETITIONS = Integer(ENV.fetch("REPETITIONS", "5"))

  ANGLE = Math::PI / 4
  SCALAR = 2.0

  V1 = Vector2d(3.0, 4.0)
  V2 = Vector2d(1.5, 2.5)
  S1 = Vector[3.0, 4.0]
  S2 = Vector[1.5, 2.5]

  # One operation, written both ways. The note names the shape of the
  # standard library version where Vector has no equivalent method.
  Case = Struct.new(:name, :ours, :theirs, :note)

  # A timed case. Times are seconds for ITERATIONS operations.
  Result = Struct.new(:name, :ours, :theirs, :note) do
    def ratio = theirs / ours
  end

  CASES = [
    Case.new("new", -> { Vector2d.new(3.0, 4.0) }, -> { Vector[3.0, 4.0] }),
    Case.new("+", -> { V1 + V2 }, -> { S1 + S2 }),
    Case.new("-", -> { V1 - V2 }, -> { S1 - S2 }),
    Case.new("* scalar", -> { V1 * SCALAR }, -> { S1 * SCALAR }),
    Case.new("* vector", -> { V1 * V2 },
             -> { S1.map2(S2) { |a, b| a * b } },
             "Vector#map2"),
    Case.new("dot", -> { V1.dot(V2) }, -> { S1.inner_product(S2) }),
    Case.new("length", -> { V1.length }, -> { S1.magnitude }),
    Case.new("normalize", -> { V1.normalize }, -> { S1.normalize }),
    Case.new("rotate", -> { V1.rotate(ANGLE) },
             lambda {
               cos = Math.cos(ANGLE)
               sin = Math.sin(ANGLE)
               Vector[(S1[0] * cos) - (S1[1] * sin),
                      (S1[0] * sin) + (S1[1] * cos)]
             },
             "the rotation written out"),
    Case.new("distance", -> { V1.distance(V2) }, -> { (S1 - S2).magnitude })
  ].freeze

  ROW = "%-12<name>s %11<ours>s %11<theirs>s %8<ratio>s"
  RULE = "-" * 45

  module_function

  def run
    results = CASES.map { |benchmark_case| measure_case(benchmark_case) }
    puts(banner + table(results) + notes(results))
  end

  def measure_case(benchmark_case)
    Result.new(benchmark_case.name,
               best_time(benchmark_case.ours),
               best_time(benchmark_case.theirs),
               benchmark_case.note)
  end

  def best_time(callable)
    (ITERATIONS / 10).times { callable.call }
    Array.new(REPETITIONS) { measure(callable) }.min
  end

  def measure(callable)
    GC.start
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ITERATIONS.times { callable.call }
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
  end

  def banner
    ["Vector2d #{Vector2d::VERSION} against the standard library Vector",
     "Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}), " \
     "#{delimited(ITERATIONS)} operations, best of #{REPETITIONS}",
     ""]
  end

  def table(results)
    [format(ROW, name: "Operation", ours: "Vector2d", theirs: "Vector",
                 ratio: "Ratio"),
     RULE,
     *results.map { |result| result_row(result) },
     RULE,
     format(ROW, name: "geomean", ours: "", theirs: "",
                 ratio: format("%.2fx", geomean(results)))]
  end

  def result_row(result)
    format(ROW,
           name: result.note ? "#{result.name} *" : result.name,
           ours: format("%.4f s", result.ours),
           theirs: format("%.4f s", result.theirs),
           ratio: format("%.2fx", result.ratio))
  end

  def notes(results)
    ["",
     "Ratio is Vector time over Vector2d time. Above 1.00x is faster.",
     *results.select(&:note).map do |result|
       "* #{result.name}: no equivalent in Vector, timed as #{result.note}."
     end]
  end

  def geomean(results)
    Math.exp(results.sum { |result| Math.log(result.ratio) } / results.length)
  end

  def delimited(number)
    number.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
  end
end

VectorComparison.run if $PROGRAM_NAME == __FILE__
