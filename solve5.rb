require 'json'

class CleanRoom
  def clean_eval(source); Object.class_eval(source) end
end

module Solver
  def self.solve(stages)
    answers = stages.transform_values do |v|
      ret = []
      (v[:source].size + 1).times do |n|
        ps = []
        ([''] + Array.new(128, &:chr)).each do |char|
          source = v[:source][...n] + char + (v[:source][(n + 1 - char.size)..] || '')
          r, w = IO.pipe
          pid = fork do
            r.close
            CleanRoom.new.clean_eval(source)
            w.puts nil
          rescue SyntaxError, StandardError => e
            if "#{e.message} (#{e.class})" == v[:expected_error]
              w.puts({ source:, n:, char: }.to_json)
            else
              w.puts nil
            end
          ensure
            w.close
          end
          w.close
          ps.push({ r:, pid: })
        end
        ps.each do |p|
          Process.waitpid(p[:pid])
          a = p[:r].read
          p[:r].close
          ret.push(JSON.parse(a, symbolize_names: true)) if a && a.size > 1
        end
      end
      ret
    end
  end
end

File.write(File.expand_path('answers5.json', __dir__), JSON.pretty_generate(
  Solver.solve(JSON.parse(File.read(File.expand_path('stages.json', __dir__)), symbolize_names: true))
))
