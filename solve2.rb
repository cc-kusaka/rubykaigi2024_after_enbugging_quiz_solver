require 'json'

class CleanRoom
  def clean_eval(source); instance_eval(source) end
end

class Solver
  def self.solve(stages)
    answers = stages.transform_values do |v|
      ret = []
      (v[:source].size + 1).times do |n|
        ([''] + Array.new(128, &:chr)).each do |char|
          source = v[:source][...n] + char + (v[:source][(n + 1 - char.size)..] || '')
          begin
            CleanRoom.new.clean_eval(source)
          rescue SyntaxError, StandardError => e
            ret.push({ source:, n:, char: }) if "#{e.message} (#{e.class})" == v[:expected_error]
          end
        end
      end
      ret
    end
  end
end

File.write(File.expand_path('answers2.json', __dir__), JSON.pretty_generate(
  Solver.solve(JSON.parse(File.read(File.expand_path('stages.json', __dir__)), symbolize_names: true))
))
