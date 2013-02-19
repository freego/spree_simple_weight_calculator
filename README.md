Spree Simple Weight Calculator
==============================

This is a shipping costs calculator based on total order weight.

You specify a weight/price table in this way:

```
5:10
10.5:15
100:50.5
```

This means:
- up to 5kg cost is 10$
- up to 10.5kg cost is 15$
- up to 100kg cost is 50.5$
- over 100kg this shipping method doesn't apply

An handling fee may also be added.

Usage
=====

Add to your Gemfile

    gem 'spree_simple_weight',  :github => 'freego/spree_simple_weight_calculator'

Create a shipping method and choose "Simple Weight" as calculator.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Credits
=======

Inspired by https://github.com/dancinglightning/spree-postal-service .


Copyright (c) 2013 Alessandro Lepore, released under the New BSD License
