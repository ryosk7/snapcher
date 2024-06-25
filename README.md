![snapcher_logo](https://github.com/ryosk7/snapcher/blob/0-1-2/logo/snapcher_logo.png?raw=true)

----------

# Snapcher
[![Gem Version](https://img.shields.io/gem/v/snapcher.svg)](http://rubygems.org/gems/snapcher)
![GitHub](https://img.shields.io/github/license/ryosk7/snapcher)
=======

**Snapcher** is an ORM extension that logs changes to specific columns to your model.

When a change is made to a specific column, the difference between before and after the change is obtained and saved.

To make it easier for analysts, save the table name, column name, and data before and after changes as separate columns.

The name of this gem comes from one of Hideo Kojima's game works, ["Snatcher"](https://en.wikipedia.org/wiki/Snatcher_(video_game)).

It was the first of his game works to introduce cinematic direction, and "Snapcher" is also the first of my gem works.

## Supported

### Snapcher supports Ruby versions:

* 3.1
* 3.2

### Snapcher supports Rails versions:

* 7.0
* 7.1

## Supported ORMs

Snapcher is currently ActiveRecord-only.

## Installation

Add the gem to your Gemfile:

```ruby
gem "snapcher"
```

Then, from your Rails app directory, create the `scannings` table:

```bash
$ rails generate snapcher:install
$ rails db:migrate
```

## Usage

Simply call `scanning` on your models.

Use `column_name:` to select the column you want to log.

```ruby
class User < ActiveRecord::Base
  scanning column_name: "name"
end
```

By default, whenever a user is created, updated or destroyed, a new scanning is created.

```ruby
user = User.create!(name: "Gillian Seed")
user.scannings.count # => 1
user.update!(name: "Mika Slayton")
user.scannings.count # => 2
user.destroy
user.scannings.count # => 3
```

Scanning contain information regarding what action was taken on the model and what changes were made.

```ruby
user.update!(name: "Mika Slayton")
snapcher = user.scannings.last
snapcher.action # => "update"
snapcher.before_params # => "Gillian Seed"
snapcher.after_params # => "Mika Slayton"
```
If the "Snatcher" column you want to capture is not user_id, you can specify this.

```ruby
class User < ActiveRecord::Base
  scanning column_name: "name", change_user_column: "id"
end
```

