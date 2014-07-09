# Part 1: RCAV + CRUD

## Setup

 1. Read the instructions completely.
 1. Clone this repository.
 1. `cd` in to the application's root folder.
 1. `bundle install`
 1. `rake db:migrate`
 1. `rake db:seed` (this will pre-populate your database tables with a few rows to save you some time)

## Introduction

The goal of this homework is to understand how to allow users to generate data for our database tables through their browsers. To do this, you will write one complete database-backed web CRUD resource.

We just need to put together what we've learned about RCAV with what we've learned about CRUDing models with Ruby.

Every web application is nothing more than a collection of related resources that users can CRUD, so understanding how each of these operations works on one table is essential. For example, Twitter allows a user to

 - sign up (**create** a row in the users table)
 - edit profile (**update** his or her row in the users table)
 - tweet (**create** a row in the statuses table)
 - delete a tweet (**destroy** that row in the statuses table)
 - I believe Twitter doesn't allow you to edit a tweet, so they don't support a route to trigger an **update** action for a row in the statuses table
 - follow/unfollow other users (**create** / **destroy** a row in the follows table)
 - favorite/unfavorite a tweet (**create** / **destroy** a row in the favorites table)
 - etc.

At the most basic level, for every interaction we want to support, we have make up a URL that will trigger a controller action which performs that interaction. Then we need to give the users a way to hit that URL (there's only two ways: either a link or a form submit button which point to that URL).

For each web resource, we usually support seven actions (with some exceptions, like Twitter not supporting editing of tweets). **The Golden Seven** actions are:

#### Create
 - new: displays a blank form to the user
 - create: receives inputs from the new form and inserts a row into the table

#### Read
 - index: displays a list of multiple rows
 - show: displays the details of one row

#### Update
 - edit: displays a pre-populated form to the user with existing data
 - update: receives inputs from the edit form and updates a row in the table

#### Delete
 - destroy: removes a row from the table

Let's get started.

## The Target

To start with, we'll keep it simple and manage just one resource: pictures. Our goal is to build an app that lets users submit URLs of pictures and add captions for them.

The original idea was for me to build a library of animated gifs to use in internal email chains with my apparently illiterate Starter League colleagues, who communicate exclusively via animated gif. [My students, however, had other ideas][2], forcing a pivot.

Anyway, that is our target: [RXNGIF][3].

### Single Picture

After you have completed the setup, you will have an application that already has a table called pictures with four rows in it. I have also already added a route to support URLs like this:

 - http://localhost:3000/picture_details/1
 - http://localhost:3000/picture_details/2
 - http://localhost:3000/picture_details/3
 - http://localhost:3000/picture_details/4

These links are currently not broken, because I did complete the RCAV flow by adding a controller, defining an action, and creating a view template. However, they don't do anything.

Your job is to make them do something. In particular, use the number after the slash to retrieve the row from the `Picture` table with the corresponding `id`, and use that row's `source` value to draw the image in the view. Toss in the `caption`, too.

Hints: Remember your [Ruby CRUD Cheat Sheet][4], and what you know about the `params` hash.

### Multiple Pictures

Next, add a second route:

    get("/all_pictures", { :controller => "pictures", :action => "index" })

Make this action work. In the end, I would like to see an unordered list of all the pictures we've got in the table. If you were to add a fifth row to the table through the Rails Console and then refresh http://localhost:3000/all_pictures, the new picture should automatically appear.

Hint: You can toss in a `width="200"` attribute on your `<img>` tag to size the images uniformly. This is a bit of a hack (we ought to do it with CSS), but we'll clean it up shortly.

### Form To Add A New Picture

We're now done with the "R" in CRUD. Our users can **Read** individual rows and collections of rows from our pictures table. But they still have to depend on us to create the data in the first place, through the Rails console or something.

Let's now attack the "C" in CRUD: **Create**. We want to allow users to generate content for our applications; that is almost always where the greatest value lies.

## New (Show a blank form)

The first step is: let's give the user a form to type some stuff in to. Add the following route:

    get("/new_picture_form", { :controller => "pictures", :action => "new" })

This action has a very simple job: draw a form in the user's browser for them to type some stuff into.

It's been a while since we've done any forms, but let's shake off the rust and recall our [essential_html][5] to craft a form for a picture with two inputs: one for the image's URL and one for a caption. Complete the RCAV and add the following HTML in the view:

    <h1>Add A New Picture</h1>

    <form>
      <div>
        <label for="the_caption">Caption:</label>
        <input id="the_caption" type="text" name="caption">
      </div>
      <div>
        <label for="image_url">Image URL:</label>
        <input id="image_url" type="text" name="source">
      </div>
      <div>
        <input type="submit" value="Create Picture">
      </div>
    </form>

There's one critical new thing: the `name="source"` and `name="caption"` attributes on the `<input>` tags. You'll see why when you type some stuff into the form (I typed "howdy" for "Caption:" and "there" for "Image URL:") and click submit:

<img src='http://kiei925.initialversion.com/uploads/default/65/a0cf5f19d5b32831.png' width="690" height="534">

It turns out that forms, when submitted, take the values that users type in to the inputs and add them to the request. However, they do it by tacking them on to the end of the URL after a `?`, in what is called a **query string**.

"Query string" is HTTP's name for a list of key/value pairs. The **keys** are the `name`s of the `<input>` tags, and the **values** are what the user typed.

In Ruby, we call a list of key/value pairs a Hash. Same thing, different notation. So

    ?sport=football&color=purple

in HTTP would translate into something like

    { :sport => "football", :color => "purple" }

in Ruby.

Why do we care? Well, it turns out that Rails does exactly that translation when it sees a query string show up on the end of one of our URLs. For example, when we clicked submit on the form that we just wrote, look what happened in our server log:

<img src='http://kiei925.initialversion.com/uploads/default/66/1c316f8aa3862fb3.png' width="690" height="313">

Rails ignores the query string as far as routing is concerned, and still sends the request to the `new` action... but it puts the extra information from the form into the `params` hash for us!

Alright, we're getting close... there's only one problem left. When a user clicks submit on the form, we probably don't want to go right back to the `new` action again. That action's job was to draw the blank form on the screen, and we're right back where we started.

We need a way to pick a different URL to send the data to when the user clicks the submit button. If we could do that, then we could set up a route for that URL, and then in the action for that route, we could pluck the information the user typed from the `params` hash and use it to create a new row in our table.

Fortunately, we can very easily pick which URL receives the data from a form: it is determined by adding an `action` attribute to the `<form>` tag, like so:

    <form action="http://localhost:3000/create_picture">

Think of the action attribute as being like the `href` attribute of the `<a>` tag. It determines where the user is sent after they click. The only difference between a form and a link is that when the user clicks a form, some extra data comes along for the ride, but either way, the user is sent to a new URL.

So now, we see something like this:

<img src='http://kiei925.initialversion.com/uploads/default/67/558cea712bdffdd3.png' width="690" height="534">

Of course, because we haven't set up a route to support `"/create_picture"`. Let's do that:

    get("/create_picture", { :controller => "pictures", :action => "create" })

Add the action and view for that route. It doesn't matter what you put in the view.

Now, if we submit the form on the new page, we see something like this in the server log:

<img src='http://kiei925.initialversion.com/uploads/default/68/525fd1077630a959.png' width="690" height="244">

Alright; now we're getting somewhere. Solutions for everything so far can be seen [here][6]. Don't forget the [practice workflow][7].

## Part II: Create (Insert a row into the table)

Write some Ruby in the `create` action to:

 - create a new row for the pictures table
 - fill in its column values by pulling the information the user typed into the form out of the `params` hash
 - save it

Once we're done, we could display a confirmation message that the information was saved in the view template, but let's instead send the user back to the index page. Remember we can use

    redirect_to("http://localhost:3000/all_pictures")

at the end of our action to send the user to a whole new URL rather than render a view template.

## Part III: Destroy (Remove a row from the table)

In `show.html.erb`, add a link under the `<h1>` that looks like this:

    <a href="http://localhost:3000/delete_picture/<%= @picture.id %>">Delete this picture</a>

Does it make sense how that link is being put together?

When I click that link, the picture should be removed and I should be redirected back to the list of all pictures.

Write a route, action, and view to make that happen. To start you off, here's a route:

    get("/delete_picture/:id", { :controller => "pictures", :action => "destroy" })

## Part IV: Edit (Show a pre-filled form)

Add another route:

    get("/edit_picture_form/:id", { :controller => "pictures", :action => "edit" })

The job of this action should be to display a form to edit an existing picture, somewhat like the `new` action.

It's a little more complicated than `new`, though, because instead of showing a blank form, you should show a form that's pre-populated with the current values for a particular picture (determined by what's after the slash).

Hint: You can pre-fill an `<input>` with the `value=""` attribute.

The `action` attributes of your edit forms should look like this:

    <form action="http://localhost:3000/update_picture/4">

so that when the user clicks submit, we can finally do the work of updating our database...

## Part V: Update (Modify an existing row in the table)

Add another route:

    get("/update_picture/:id", { :controller => "pictures", :action => "update" })

The job of this action is to receive data from an edit form, retrieve the corresponding row from the table, and update it with the revised information. Give it a shot. Afterwards, try to redirect to the details page for the picture that was just updated (how do we put together the URL for any given picture?).

## Conclusion

If we can connect all these dots, we will have completed one entire database-backed CRUD web resource. Every web application is essentially just a collection of multiple of these resources; they are the building blocks of everything we do, and we'll just cruise from here.

Struggle with it, come up with questions, and post them on the forum. Other things you can do to practice:

 - Rebuild Fortune Teller from scratch, but this time, build Zodiac as a database-backed web resource from the get-go.
 - Add Bootstrap to Rxngif.
 - Think of the most important resource in one of your application ideas and build a CRUD web app for it.

  [1]: https://github.com/s14/rxngif
  [2]: http://rxngif.com/
  [3]: http://rxngif.com/
  [4]: https://lanternhq.com/1/courses/140/resources/1293-crud-with-ruby-cheatsheet
  [5]: https://github.com/s14/essential_html
  [6]: https://github.com/s14/rxngif_solutions/commits/master
  [7]: https://lanternhq.com/1/courses/140/resources/1146-homework-workflow

