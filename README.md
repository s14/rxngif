# RXNGIF

In this application, we will finally take everything we've learned about RCAV and put it together with what we've learned about models and database tables to create a functioning CRUD (Create, Read, Update, Delete) web application.

First, we'll allow users to create, retrieve, update, and delete pictures.

## Set Up

 - **Fork** and *then* clone
 - `cd` into the application's root folder
 - `bundle install`
 - I already added a model file, `picture.rb`, that defines the `Picture` class and inherits from `ActiveRecord::Base`
 - `rake ez:tables` to create a pictures table (I already wrote `db/models.yml` for you)
 - `rake db:seed`
 - Start up your Rails Console and check out your pictures table. How many pictures are there currently?
