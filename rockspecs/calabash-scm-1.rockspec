package = 'calabash'
version = 'scm-1'
source = {
   url = 'git://github.com/pib/calabash.git'
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