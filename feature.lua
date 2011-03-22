local lpeg = require 'lpeg'
local table = table
local pairs = pairs

module(...)

local locale = lpeg.locale()
local Cg, Ct, P, S, V = lpeg.Cg, lpeg.Ct, lpeg.P, lpeg.P, lpeg.V

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

G = Ct{
   "Feature",
   Name = Cg((1 - newline)^1, 'name'),
   Feature = (P"Feature:" * space^0 * V'Name' * (newline * V'Description')^-1 *
           Cg(Ct(V'Scenario'^0), 'scenarios')),
   Description = Cg(Ct(V'PlainLine'^1) / concat_lines,
                         'description'),
   PlainLine = i_space * Cg((1 - newline - P'|') * (1 - newline)^1) * newline,
   HashValue = Cg((non_space - '|') * (i_space * (non_space - '|'))^0),
   HashtableLine = Ct(i_space * P'|' * (i_space * V'HashValue' * i_space * '|')^1 * i_space * newline),
   Hashtable = Ct(V'HashtableLine'^1) / format_hash,
   Step = Ct(Cg(V'PlainLine', 'name') * Cg(V'Hashtable', 'hashes')^0),
   Scenario = Ct(
      space^0 * "Scenario:" * space * V'Name' * newline *
         Cg(Ct(V'Step'^0), 'steps'))
}

function parse(feature_string)
   return lpeg.match(G, feature_string)
end