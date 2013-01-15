AgreeList
==============

Install and Use
---------------
```ruby
git clone git://github.com/AgreeList/agreelist-test.git
cd agreelist-test
bundle install
```

Example:
--------
List of people who agree that "assault weapons should be banned"

Using agreelist.rb
------------------
```ruby
irb
require 'agreelist'
s = Statement.new("assault weapons should be banned")
s.supporters
```

Using Fluidinfo API
-------------------
```ruby
irb
require 'fluidinfo'
f = Fluidinfo::Client
f.get("/values", :query => "has agreelist.com/agree_assault_weapons_should_be_banned", :tags => ["fluiddb/username", [en.wikipedia.org/url])
```


License
==============
Released under the MIT License.
