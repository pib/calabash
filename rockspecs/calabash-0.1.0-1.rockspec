package = 'calabash'
version = '0.1.0-1'
source = {
   url = 'http://github.com/pib/calabash/tarball/0.1.0',
   md5 = 'c468337344a16bfb0a2cdcdf84dc7ae9'
}
description = {
   summary = 'A cucumber-like BDD library on top of telescope.',
   detailed = [[
         Calabash is a domain-specific language for behavior-driven-development,
         modelled after Cucumber (http://cukes.info/).
   ]],
   license = 'MIT/X11',
   homepage = 'http://github.com/pib/calabash'
}
dependencies = {
   'lua >= 5.1',
   'telescope >= 0.4',
   'lpeg >= 0.10',
   'luafilesystem >= 1.5'
}

build = {
   type = 'none',
   install = {
      lua = {
         'calabash.lua'
      },
      bin = {
         'cbsh'
      }
   }
}