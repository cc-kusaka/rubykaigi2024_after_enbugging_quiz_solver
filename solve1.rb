require 'json'

stages = JSON.parse(File.read(File.expand_path('stages.json', __dir__)), symbolize_names: true)
answers = stages.transform_values do |v|
  ret = []
  (v[:source].size + 1).times do |n|
    ([''] + Array.new(128, &:chr)).each do |char|
      source = v[:source][...n] + char + (v[:source][(n + 1 - char.size)..] || '')
      begin
        eval(source)
      rescue SyntaxError, StandardError => e
        ret.push({ source:, n:, char: }) if "#{e.message} (#{e.class})" == v[:expected_error]
      end
    end
  end
  ret
end
File.write(File.expand_path('answers.json', __dir__), JSON.pretty_generate(answers))
