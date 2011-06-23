# Slacker
Behavior Driven Development for SQL Server

# Description
__Slacker__ is a Ruby (RSpec-based) framework for developing automated tests for SQL Server programmable objects such as stored procedures and scalar/table functions.

# Install
    gem install slacker

__Slacker__ automatically installs the following gems:

* rspec 2.5.0
* ruby-odbc 0.99994

__Slacker__ runs on Windows and Linux.<br/>
Before installing __Slacker__ on Windows, you need to install the Windows DevKit (ruby-odbc contains native extensions).

# LICENSE
(The MIT License)

Copyright (c) 2011 Vassil Kovatchev

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.