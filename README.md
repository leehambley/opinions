# Opinions

**Store opinions in Redis.** *Opinions* allows the storage of opinions in
Redis, a fast and atomic structured data store. If one's users *hate*, *love*,
*appreciate*, *despise* or *just-don-t-care*, one can store that easily via a
simple API.

It is not bound to *ActiveRecord*, or any other big libraries, any class exposing a
public `id` method can be used. The `id` method is not required to be
numerical.

``` ruby
class CatPicture < ActiveRecord::Base

  include Opinions::Pollable
  opinions :like, :dislike

end
```

This simple example shows that in our logical model cat pictures can either be
liked, or disliked. The following methods are available to all instances of `CatPicture`:

 * `like_by(...)`
 * `cancel_like_by(...)`
 * `like_votes()`
 * `dialike_by(...)`
 * `cancel_dislike_by(...)`
 * `dislike_votes()`

On the flip-side, one needs a way to share one's feelings, from the model representing
a user, or rater, or similar, one can easily use the opposite:

``` ruby
class User < ActiveRecord::Base

  include Opinions::Opinionated
  opinions :like, :dislike

end
```

This module will mix-into the `User` the following methods:

 * `like(...)`
 * `dislike(...)`
 * `cancel_like(...)`
 * `cancel_dislike(...)`
 * `like_opinions()`
 * `dislike_opinions()`
 * `have_like_on(...)`
 * `have_dislike_on(...)`

These methods can be passed instances of any class which has those opinions defined.

It should be absolutely trivial to extend these to any behaviour you
need. 

**Note:** It is by design that these methods do not read particularly
naturally, you are invited to read the source, and tests of the
Pollable, and Opinionated modules and implement them in a way which
better reflects the grammar of your application, and desired *Opinions*.
Think of these modules as examples, something to expand upon.

## Inspiration

*Opinions* is inspired by [`schneems/likeable`](https://github.com/schneems/Likeable). A few
things concerned me about that project, so I wrote *opinions* after contributing
significant fixes to *likeable*.

### What's different from *Likeable*?

* There are no hard-coded assumptions about which opinions you'll be using, that's
  up to your project needs.

* There are no callbacks, these are better handled with observers, either in the
  classical OOP meaning of the word, or your framework's pattern. (In Rails they're
  the same thing)

* A *very* comprehensive test suite, written with *MiniTest*. *Likeable* is quite
  simple, and has about ~35 tests, that might be OK for you, and Gowalla, but I'd
  feel better with real unit, functional and integration tests.

* It's not *totally* bound to Redis. Internally there's a Key/Value store proxy, this
  uses Redis out of the box, but it should be easy for someone to replace this with
  MongoDB, Riak, DynamoDB, SQLite, etc.

* It does not depend on *ActiveSupport*, *likeable* depends on *keytar*, which depends
  on `ActiveSupport` for inflection and *ActiveSupport::Concern.*

* It does not depend on `Keytar`, Keytar is a handy tool for building NoSQL keys for
  objects, however it's a little bit over-featured for this use-case.

* *Likeable* stores timestamps as floating point numbers, I'm confused
  by this. Sub-second resoltion seems unusual here, and isn't easy for a
  human being to read. *Opinions* uses the time format: `%Y-%m-%d %H:%M:%S %z`.

* *Likeable* doesn't store *symetrical* relationships, using *Likeable*
  it's only possible to have one type of object sharing opinions on any
  other (*Users*). *Opinions* stores the relationship symetrically, so
  many kinds of objects can store many kinds of opinions.

* *Likeable* stores the class name unaltered, this can cause problems
  with namespaced classes as the class namespace separator in Ruby is
  `::`, this conflicts with the sepatator traditionally used in Redis.
  *Opinions* stores the class names processed with an *ActiveSupport*
  inspired `underscore` method which uses the forward slash character to
  represent a namespace delimiter.

## Migrating from *Likeable*

Unfortunately the key structure is sufficiently different that you'll
need to explicitly migrate, there's no shortcut. The key to migrating
sucessfully is that the `vote(target)` and `vote_by(object)` methods
take an optional time parameter in the second position. If this is
passed then it will

## Installation

Add this line to your application's Gemfile:

    gem 'opinions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opinions

## Usage

To get started simply require the gem as above, and add an initializer
or hook to your application.

The Gem must be configured with at LEAST this minimum:

``` ruby
Opinions.backend       = Opinions::RedisBackend.new
Opinions.backebd.redis = Redis.new(...)
```

The `Redis` object here is provided by the `redis-rb` Gem, and can
accept any of the standard port/host/db options, in any of the formats
that the gem supports.

One may also choose to use (and is advised to use) *Redis::Namespace* to
keep the large number of keys generated by this application to their own
scope.

The *backend* API is simple, and it should be trivial to swap this for
an alternative, if you are interested in using a store other than Redis.

The examples at the top of this docuemnt serve as usage examples. You
may also learn something from reading the **Integration** tests.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Sample Key Structure

Given the following example, the key
structure would be:

``` ruby
class Recommendation
  iclude Opinions::Pollable
  opinions :like
end

class User
  include Opinions::Opinionated
  opinions :like
end

User.find(123).like(Recommendation.find(789)
User.find(123).like(Recommendation.find(987)

User.find(321).like(Recommendation.find(789)
```

The resulting Redis structure would be something like this:

``` text
user:like:123:recommendation
  "789" "2012-11-13 00:01:02 +01:00"
  "987" "2011-02-01 00:03:01 +01:00"

user:like:321:recommendation
  "789" "2014-02-01 17:15:01 +01:00"

recommendation:like:789:user
  "123" "2012-11-13 00:01:02 +01:00"
  "321" "2014-02-01 17:15:01 +01:00"

recommendation:like:987:user
  "123" "2011-02-01 00:03:01 +01:00"
```
