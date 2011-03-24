require 'telescope'
require 'feature'

local steps = feature.load_steps('features/steps.lua')


local contexts = {}
local feature_str = io.open('features/generator.feature'):read('*all')
feature.generate_contexts(feature_str, steps, contexts)
feature_str = io.open('features/parser.feature'):read('*all')
feature.generate_contexts(feature_str, steps, contexts)

local buffer = {}
local results = telescope.run(contexts, callbacks, test_pattern)
local summary, data = telescope.summary_report(contexts, results)

table.insert(buffer, telescope.test_report(contexts, results))

table.insert(buffer, summary)
local report = telescope.error_report(contexts, results)
if report then
   table.insert(buffer, "")
   table.insert(buffer, report)
end

if #buffer > 0 then print(table.concat(buffer, "\n")) end

for _, v in pairs(results) do
  if v.status_code == telescope.status_codes.err or
    v.status_code == telescope.status_codes.fail then
    os.exit(1)
  end
end
