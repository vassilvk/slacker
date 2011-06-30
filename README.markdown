# Slacker
Behavior Driven Development for SQL Server

# Description
Slacker is a Ruby (RSpec-based) framework for developing automated tests for SQL Server programmable objects such as stored procedures and scalar/table functions.

# Installation
    gem install slacker

### Requirements

* Ruby 1.9.2.

Runs on Windows and Linux.

_Note_: Before installing on Windows, you need to install the [Ruby Windows Development Kit](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit).

# Quick Start
To create a new Slacker project, run the following command:

    slacker_new my_project

This will create a new project directory `my_project`.

Navigate to the new project directory and modify file `database.yml` to tell Slacker which database to connect to.

Run Slacker:

    slacker

If all is good, you should see something like this:

    my_database (my_server)
    .....

    Finished in 0.05222 seconds
    7 examples, 0 failures

Next, check out sample file `my_project\spec\sample_1.rb` to see the BDD specification you just executed.

Also take a look at the SQL files generated in folder `my_project\debug\passed_examples`. Those are the actual SQL scripts Slacker generated and executed against your database.

# Resources

* [__Documentation__](https://github.com/vassilvk/slacker/wiki)
* [__Mailing List__](https://groups.google.com/forum/#!forum/ruby_slacker)


# LICENSE
(The MIT License)

Copyright (c) 2011 Vassil Kovatchev

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.