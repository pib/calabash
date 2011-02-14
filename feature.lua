local lpeg = require 'lpeg'
local table = table
module(...)

local locale = lpeg.locale()
local V, P, S = lpeg.V, lpeg.P, lpeg.S

local space = locale.space
local newline = S"\n" + S"\r\n"

function concat_lines(...)
   table.concat(..., '\n')
end

G = lpeg.Ct{
   "Feature",
   Feature = P"Feature:" * space^0 * (lpeg.Cg((1 - newline)^1, 'name')) * (newline * V'Description')^0,
   Description = lpeg.Cg(lpeg.Ct(V'PlainLine'^1 * newline^0) / concat_lines,
                         'description'),
   PlainLine = ((space^0) * lpeg.Cg((1 - newline)^1) * newline^-1)
}

function parse(feature_string)
   return lpeg.match(G, feature_string)
end