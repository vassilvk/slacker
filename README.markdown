# Slacker
Behavior Driven Development for SQL Server

# Description
__Slacker__ is a Ruby (RSpec-based) framework for developing automated tests for SQL Server programmable objects such as stored procedures and scalar/table functions.

# Installation
    gem install slacker

## Requirements

__Slacker__ requires Ruby 1.9.2.

Runs on Windows and Linux.

Before installing __Slacker__ on Windows, you need to install the [Ruby Windows Development Kit](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit) (__ruby-odbc__ contains native extensions).

# Usage
To create a __Slacker__ project, run the following command:

    slacker_new my_project

This will create a directory `my_project` in your current directory and will populate it with the files of a  __Slacker__ project scaffold.

Navigate to your new project directory and modify file `database.yml` to tell __Slacker__ which database it should connect to.

Then while in your project directory run __Slacker__:

    slacker

If all is good, you should see something like this:

    my_database (my_server)
    .....

    Finished in 0.05222 seconds
    5 examples, 0 failures

Next, check out sample file `my_project\spec\sample_1.rb` to see the BDD specification you just executed.

# Documentation TODO

Document the following features:

* Slacker project
 * Project structure
 * Configuration
* Running Slacker
* DSL
* SQL Templates
* Data Fixtures
* Test Matrices
* Generated SQL
* Debugging


# LICENSE
(The MIT License)

Copyright (c) 2011 Vassil Kovatchev

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.