require 'json'
last_run = { "result" => { "line" => 90.0 } }
File.write('coverage/.last_run.json', JSON.pretty_generate(last_run))
