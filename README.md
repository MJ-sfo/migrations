<!--
Creator: @cofauver, @tgaff
Market: SF
-->

![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png)
# Migrations

### Why is this important?
<!-- framing the "why" in big-picture/real world examples -->
*This workshop is important because:*

Migrations are the history of commands that have adjusted your DB to bring it to its current state. When working on an application, you'll need to change the structure of the tables in the database to adjust to changing data storage needs. In exploring migrations, you'll learn how to manipulate and use table columns.

### What are the objectives?
<!-- specific/measurable goal for students to achieve -->
*After this workshop, developers will be able to:*

- Be able to add/remove columns from the database.
- Be able to explain when it is OK to edit a migration.
- Alter an existing column.

### Where should we be now?
<!-- call out the skills that are prerequisites -->
*Before this workshop, developers should already be able to:*

- Scaffold out a simple, single-resource Rails CRUD app.
- Generate a model and migration simultaneously using `rails g model ...`
- Describe the role that ActiveRecord plays in your application.

## Migrations

> Definition: In software engineering, schema migration (also database migration, database change management) refers to the management of incremental, reversible changes to relational database schemas. A schema migration is performed on a database whenever it is necessary to update or revert that database's schema to some newer or older version. [1][1]

* Given that:
  * We cannot know the database table structures precisely when we begin the app.
  * The structure changes as business needs evolve.
  * We must not damage or lose production database records.
* Then we must make small changes to the database structure over time, .

Migrations give us the ability to make small and incremental changes to our database and to make those same changes to one or more production datasets.  


### Creating tables OR Rails Model review

```
rails g model talk topic:string duration:integer
```

The above command, you'll recall, creates 2 new files.  

1. app/models/talk.rb - a new Rails Model
1. db/migrate/1234566789_create_talks.rb - a database migration.

Typically we'll edit both of these files as needed to get the database structure we want and set any validations we want to run in the model.

Finally you of course must run `rails db:migrate`.  When you run rails `db:migrate` it alters the `schema.rb` file.  Then you commit the above files as well as the `db/schema.rb` file.

>Note: Never directly edit schema.rb

#### Practice 1 - Create a Table

Let's say we're building a website to sell used cars.  We know we need a few basic things to keep track of our cars; things like:

* make
* model
* year

Let's write a migration to track these on a new **Car** model.  But first create a new rails app; from the directory you do your wdi work in:

```
$ rails new practice -T -d=postgresql
```

(Of course you should CD into this app.)
>We are using the -T (aka --skip-test-unit) and -d postgresql (aka --database=postgresql) options today -- postgresql is our preferred database. We'll talk about tests another day.

<details><summary>What's the command to generate the new car model and migration?  Use make, model, and year as column names.</summary>
`rails g model car make:string model:string year:integer`
</details>

What does this give us?

Migration:

```ruby
class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :make
      t.string :model
      t.integer :year

      t.timestamps null: false
    end
  end
end
```

<details>
<summary>After generating this, what do we need to run?</summary>
`rails db:migrate`
</details>

This will also change the file `db/schema.rb` updating it to include the new table structure.

Afterwards you should commit your changes before moving on to work with this table.

(STOP and COMMIT!)

### Migrations are forever

Once a migration has been merged into the master branch; it is **forever**.
<details>
<summary>But it's a little more complicated...</summary>
Above we said that once a migration is merged into master, it is permanent.  But really we need to think about the following:

1. preservation of production data
1. other developers

If your migration is run on any sort of staging or production environment and you don't, in ordinary practice, wipe that database, then that migration is set-in-stone.  Your top concern when writing a migration, is to not do any damage to production data.  Your users will never forgive you if you accidentally delete pictures of their cat Fluffy.

If other developers are already working with your migration (perhaps it was merged to a shared feature branch), then it is set-in-stone.  If you were to change your migration now they would have to update their branch to match and be very very certain that they did not accidentally introduce a different variation of your migration.

That being said, if your changes haven't reached anywhere else yet, you could still re-write your migration.
</details>

![](http://i.giphy.com/6KEr8zBleOFwI.gif)

After your changes have left your machine the only way to undo or redo is to _write a new migration_ to make the required changes.  Why?  

### Changing existing tables

In some cases we may already have a table but need to add a new column to it.  Alternatively we may want to remove an existing column.  How can we do this?

Rails has migration generators for adding and removing tables, using respectively "AddXXXToYYY" or "RemoveXXXFromYYY" (you may also use lower_snake_case).  For both of these "XXX" is a column-name and "YYY" represents the model.

#### Practice 2 - Add a Column

Let's a `vin` column to our `cars` table.

To generate an empty migration file, you could run:

`rails generate migration AddVinToCars`

```ruby
# db/migrate/yyyymmddnnnn_add_vin_to_cars.rb
class AddVinToCars < ActiveRecord::Migration
  def change
    # empty!
  end
end
```
^ Not much there right? ^

Then you could manually edit the new migration to properly set the "vin" datatype (likely a String)...

**But there's a better way!!!**

Let's tell rails on the command-line which data-types to use and have it generate all the appropriate code.

Add a vin column to the Car model: `rails generate migration AddVinToCars vin:string`

This generates a migration like (which you'll have to check carefully):

```ruby
class AddVinToCars < ActiveRecord::Migration
  def change
    add_column :cars, :vin, :string
  end
end
```

> Note: you can add multiple columns simultaneously.

Nice work! Now, don't forget!
* `rails db:migrate:status` --> check for "down" migrations.
* `rails db:migrate` --> apply your "down" changes to the database
* `rails db:migrate:status` --> verify all your migrations are "up".

(STOP and COMMIT!)

#### Practice 3 - Remove a Column

We can also remove a column:

* remove the `vin` column from the `cars` table: `rails generate migration remove_vin_from_cars vin:string`

This generates a migration like:

```rb
class RemoveStreetAddressFromUsers < ActiveRecord::Migration
  def change
    #             :table, :column, :type
    remove_column :cars,  :vin,    :string
  end
end
```
> Note: you must still specify the `column_name:datatype` when doing a remove. (Migrations should be reversible.)

Don't forget to run your migrations!
* `rails db:migrate:status` --> check for "down" migrations.
* `rails db:migrate` --> apply your "down" changes to the database
* `rails db:migrate:status` --> verify all your migrations are "up".

(STOP and COMMIT!)

> Pro-Tip: We advise you to always commit your migration files separately from your `schema.rb`.

#### Practice 2 -- Add a column

Now let's say we've decided to add a `color` column to our `cars` table.  How can we do that?

* What datatype is color?

<details>
<summary>What is the terminal command to create the new migration to change the cars table?</summary>
`rails g migration AddColorToCars color:string`
</details>

Don't forget to run your migrations!
* `rails db:migrate:status` --> check for "down" migrations.
* `rails db:migrate` --> apply your "down" changes to the database
* `rails db:migrate:status` --> verify all your migrations are "up".

(STOP and COMMIT!)

> Pro-Tip: We advise you to always commit your migration files separately from your `schema.rb`.

### Undo

Previously we said that migrations are forever, but that really only applies if we've pushed (or deployed) our local code.  We are permitted to make changes to the last migration if it hasn't left our local development environment yet.

We can rollback (reverse) a migration using the command:

```
rails db:rollback
```

Providing a step parameter allows us to rollback a specific number of migrations:

`rails db:rollback STEP=2` rollsback 2 migrations.

You can also use the date stamp on the migrations to migrate (up or down) to a specific version:

`rails db:migrate VERSION=20080906120000`

> You are encouged to then run `rails db:migrate:status` to verify that your most recent migration(s) are listed as "down".

Once you've rolled-back, you're welcome to manually make changes to the migration file.

You may also safely delete the file (e.g. `git rm db/migrate/yyymmddnnnn_add_color_to_cars.rb`).

> Warning: Never delete a migration that is "up". You *MUST* first rollback your migration before deleting the migration file.

#### Practice 3 -- Undo adding `color` to `cars`.

<details>
<summary>How can we reverse the last migration we ran? (the one to add color)</summary>
`rails db:rollback`
</details>

Once we've reversed that migration, let's delete it so we can make a new one.  `git rm db/migrate/yyyymmddnnnn_add_color_to_cars.rb`

(STOP and COMMIT)

Now let's create a new migration that adds `color` and `mileage` as columns.

* What datatype is mileage?

<details><summary>What's the command to create a migration to add `color` and mileage to the `cars` table?</summary>
`rails g migration AddDetailsToCars color:string mileage:decimal`

This generates:

```ruby
class AddDetailsToCars < ActiveRecord::Migration
  def change
    add_column :cars, :color, :string
    add_column :cars, :mileage, :decimal
  end
end
```

</details>

Don't forget to run your migrations!
* `rails db:migrate:status` --> check for "down" migrations.
* `rails db:migrate` --> apply your "down" changes to the database
* `rails db:migrate:status` --> verify all your migrations are "up".

(STOP and COMMIT!)

> Pro-Tip: We advise you to always commit your migration files separately from your `schema.rb`.

### The Rules of Migrations

* Never edit/remove a migration once it is merged ("up").
* Never directly modify the `db/schema.rb` file. (Only the `rails db:migrate` command is allowed to update `schema.rb`).
* Never alter the database structure without a migration file.
* Make sure that all your local migrations are "up" before pushing/deploying code. Your `schema.rb` should always reflect the _current_ state of the database. You `schema.rb` should be the same on every machine.

### List of Column DataTypes

Basic list:

* :binary
* :boolean
* :date
* :datetime
* :decimal
* :float
* :integer
* :primary_key
* :references
* :string
* :text
* :time
* :timestamp

See http://stackoverflow.com/questions/17918117/rails-4-datatypes


> Note: 90% of the time prefer *decimal* over *float* [2][2]

> Note: Prefer *text* over *string* if on postgresql (maybe).  Otherwise prefer *string* over *text* when your data is definitely always less than 255.  [3][3]

> Note: prefer datetime unless you have a specific reason to use one of the others.  ActiveRecord has extra tools for datetime

### Bonus - default values, constraints and indexes

There are a few other things you can do with migrations, including:

* setting a default value for a field (admin: false) (accepted_eula: false)
* making a field required by preventing NULL (require that a user have a name)
* creating indexes to speed up search

Let's look at how we can do this.

#### Default values

We can set a database rule that will make a default value for a particular attribute (if it is unfilled).

```rb
class AddEulaAcceptedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :eula_accepted, :boolean, default: false
  end
end
```


#### Required fields

We can set a database rule that requires an attribute to NOT be null.

```rb
class RequireUserName < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :name, :string, null: false
  end
end
```

> Note: this sets it in the DB, but doesn't work well with `model.valid?`.  There are business reasons for doing this (perhaps your database is used by another app as well) but it may also be ideal to use Model Validations.

Later you'll look at **model validations** which may be a better way to set default values and required fields.

#### Indexes

Indexing columns you frequently search for records on will greatly increase the speed at which the database can search those columns.  With many users performing queries, this can save your response times.

```rb
class AddIndexToUserName < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :name
  end
end
```

Also you can generate indexes when creating columns: `$ bin/rails generate migration AddPartNumberToProducts part_number:string:index`

> What algorithm do you suppose is used for indexing?

### Other commands

* `rails db:schema:load` - create your database by reading the `schema.rb` file (often faster than running *hundreds* of migration files sequentially).
* `rails db:setup` - similar to running `rails db:create db:migrate db:seed`
* `rails db:drop` - destroy the database (if you run this in production you're FIRED!)
