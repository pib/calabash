local lpeg = require 'lpeg'
local unpack = unpack
local telescope = require 'telescope'

module(..., package.seeall)

local locale = lpeg.locale()
local C, Cb, Cg, Ct, P, S, V = lpeg.C, lpeg.Cb, lpeg.Cg, lpeg.Ct, lpeg.P, lpeg.P, lpeg.V

local space = locale.space
local newline = S"\n" + S"\r\n"
local i_space = (space - newline)^0 -- ignored space
local non_space = (1 - space)^1 -- group of at least one non-space character

function concat_lines(...) return table.concat(..., '\n') end

function format_hash(rows)
   local hashes = {}
   local keys
   for i, values in pairs(rows) do
      if i == 1 then
         keys = values
      else
         local hash = {}
         for i=1,#keys do
            hash[keys[i]] = values[i]
         end
         table.insert(hashes, hash)
      end
   end
   return hashes
end

function format_multiline(multi)
   local lines = {}
   local indent = (P(multi.indent) * C(P(1)^0)) + C(P(1)^0)
   for _, line in pairs(multi.lines) do
      table.insert(lines, lpeg.match(indent, line))
   end
   return table.concat(lines, '\n')
end

G = Ct{
   "Feature",
   Name = Cg((1 - newline)^1, 'name'),
   Feature = (P"Feature:" * space^0 * V'Name' * (newline * V'Description')^-1 *
           Cg(Ct(V'Scenario'^0), 'scenarios')),
   Description = Cg(Ct(V'PlainLine'^1) / concat_lines,
                         'description'),
   PlainLine = i_space * Cg((1 - newline - '|' - '"""' - "'''") * (1 - newline)^1) * newline,

   HashValue = Cg(((non_space - '|') * (i_space * (non_space - '|'))^0)^0),
   HashtableLine = Ct(i_space * P'|' * (i_space * V'HashValue' * i_space * '|')^1 * i_space * newline),
   Hashtable = Ct(V'HashtableLine'^1) / format_hash,

   MultiSLines = Cg(Ct((Cg((1 - P"'''" - newline)^0) * newline)^0), 'lines'),
   MultiDLines = Cg(Ct((Cg((1 - P'"""' - newline)^0) * newline)^0), 'lines'),
   MultiSingle = P"'''" * newline * V'MultiSLines' * i_space * P"'''",
   MultiDouble = P'"""' * newline * V'MultiDLines' * i_space * P'"""',
   Multiline = Ct(Cg(i_space, 'indent') * (V'MultiSingle' + V'MultiDouble') * newline) / format_multiline,

   Step = Ct(Cg(V'PlainLine', 'name') * Cg(V'Hashtable', 'hashes')^0 * Cg(V'Multiline', 'multiline')^0),
   Scenario = Ct(
      space^0 * "Scenario:" * space * V'Name' * newline *
         Cg(Ct(V'Step'^0), 'steps'))
}

function parse(feature_string)
   return lpeg.match(G, feature_string)
end

wildcard = P'(.*)' + '"(.*)"' + "'(.*)'"
non_wildcard = (1 - wildcard)^1
step_patt = Ct(C(non_wildcard + wildcard)^1)

wildcard_nospace = C((1 - space)^1)
wildcard_single_q = P"'" * C((P"\\'" + (1 - P"'"))^0) * "'"
wildcard_double_q = P'"' * C((P'\\"' + (1 - P'"'))^0) * '"'

function make_step_pattern(name)
      local parts = lpeg.match(step_patt, name)
      local patt = P''
      for _, part in pairs(parts) do
         if part == '(.*)' then
            patt = patt * wildcard_nospace
         elseif part == '"(.*)"' then
            patt = patt * wildcard_double_q
         elseif part == "'(.*)'" then
            patt = patt * wildcard_single_q
         else
            patt = patt * P(part)
         end
      end
      return Ct((1 - patt)^0 * patt)
end

function load_steps(path)
   local env = getfenv()
   local steps = {}
   local function step(name, fn)
      local patt = make_step_pattern(name)
      steps[patt] = fn
   end

   for k, v in pairs(telescope.assertions) do
      setfenv(v, env)
      env[k] = v
   end


   setmetatable(env, {__index = _G})
   env.step = step
   local func, err = assert(loadfile(path))
   if err then error(err) end
   setfenv(func, env)()
   
   return steps
end

function make_step(step, steps)
   for patt, step_fn in pairs(steps) do
      local params = lpeg.match(patt, step.name)
      if params then
         table.insert(params, 1, step)
         return function() step_fn(unpack(params)) end
      end
   end
   error('No matching step definition for "' .. step.name .. '"!')
end

function generate_context(feature_str, steps, contexts)
   local feature = parse(feature_str)

   contexts = contexts or {} -- telescope contexts generated
   local ctx = {} -- internal context handed to each test
   local current_scenario = 0

   -- telescope context format:
   --   for features: {context = true, name = "Feature name", parent = 0}
   --   for scenarios: {context = true, name = "Scenario name", parent = 1}
   --   for steps: {context_name = "Scenario name", name = "Step name", parent = parent_index, test = function...}
   
   table.insert(contexts, {context = true, name = feature.name, parent = 0})
   for _, scenario in pairs(feature.scenarios) do
      table.insert(contexts, {context = true, name = scenario.name, parent = 1})
      current_scenario = #contexts
      for _, step in pairs(scenario.steps) do
         step.context = ctx
         local step_fn = make_step(step, steps)
         table.insert(contexts, {context_name = contexts[current_scenario].name,
                                 name = step.name, parent = current_scenario, test = step_fn})
      end
   end
   return contexts
end