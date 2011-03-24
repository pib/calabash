Calabash - BDD DSL for Lua
==========================

Calabash is a domain-specific language for behavior-driven-development,
modelled after [Cucumber](http://cukes.info/).
 
Using calabash
--------------

First, write a .feature file (in a features directory in your
project), then define the steps in features/steps.lua, then write code
to pass those tests.

For a good example of how to use calabash, take a look in the features
directory in this repository.

Run the tests by running:

    $ cbsh

Right now there are no command-line options; it just runs all the
tests in the features directory and prints out telescope's more
verbose output.

## License ##

The MIT License

Copyright (c) 2009-2010 [Norman Clarke](mailto:norman@njclarke.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.