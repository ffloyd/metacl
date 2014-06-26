# Metacl

DSL that generates C code for different computation platforms (pure C, OpenCL, Intel Phi)

## Installation

Add this line to your application's Gemfile:

    gem 'metacl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metacl

## Usage

    $ metacl some.mcl
    
Translates some.mcl to some.cpp. Example compile command for OS X (also you must have cl.hpp in OpenCL folder):

    $ clang++ -framework OpenCL -stdlib=libc++ -std=gnu++11 some.cpp

## Contributing

1. Fork it ( http://github.com/<my-github-username>/metacl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
