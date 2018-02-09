
Goals:

Make a clean install of Rails 5.1 on Debian with the following features:

Postgresql as database
No coffeescript
Scaffolding generators should use bootstrap
Use simple_form
Ruby 2.2.6
No turbolinks
Haml rather than erb
rvm

I decided to use Ruby 2.2.6

Install rvm. Ruby version manager. Note that the docker ruby containers prefer rvm over rbenv

Set ruby version

echo "2.2.6" &gt; .ruby-version

Install ruby 2.2.6

rvm install ruby-2.2.6

I had to install bundler

gem install bundler


install Rails

gem install rails -v 5.1.4

or just

gem install rails

Create a new rails project using postgresql. I decided to skip coffeescript, spring, test-unit, and turbolinks. I used coffee-script heavily when it first came out in (2010-2013). Time to get back to plain javascript. In this case I'm setting up a rails project for small and demo projects, so I think I don't need turbolinks.

rails new blog -d postgresql --skip-coffee --skip-spring --skip-test-unit --skip-turbolinks

Change into new directory

cd blog

This sets ruby for this directory

rvm --ruby-version use 2.2.6@my_blog --create

Now lets configure the site to use twitter bootstrap, haml, and simple-form
Add the following to the Gemfile

#gem "therubyracer" - don't need if you are using static bootstrap .
#  gem "less-rails" 
gem "twitter-bootstrap-rails"
gem "simple_form"
gem "haml-rails"

bundle install

Create the database

createdb blog_development

or (also creates blog_test database)

rake db:create

I use simple_form. Install simple_form with the bootstrap option

rails generate simple_form:install --bootstrap

Generate app/views/layouts/application.html.haml

rails g bootstrap:layout application

Edit application.html.haml and remove lines similar to apple-one-touch...

cd app/views/layouts
vi application.html.haml


rake assets:precompile

Review steps for installing bootstrap.

double check the order of running the following

rails generate simple_form:install --bootstrap 

Scaffold countries and cities

rails g scaffold city name:string country:references
rails g scaffold country name:string

The scaffold generator generates lots of unused files. One approach is to run the generator in a separate (dummy) rails project and copy over the files you need. I did some research on how to disable generation of (unwanted files). The result is:
config/initilizers/generators.rb

Rails.application.config.generators do |g|
        g.helper nil
        g.assets nil
        g.view_specs nil
        g.template_engine :haml
        g.test_framework  false, fixture: false
        g.stylesheets     nil
        g.javascripts     nil
        g.jbuilder false
end

This stops the generator from generating all sorts of things. The generator still generates system test files.



The simple_form generator is cool because it knows about associations.
Check app/views/cities/_form.html.haml

Note: The simple_form view generators and the bootstrap theme generators differ when generating input forms. Use 

rails g bootstrap:themed Cities

and then use

rails g scaffold city name:string country:references

for the _form.html.haml only

To install bootstrap's css and js files I went here:

https://getbootstrap.com/docs/4.0/getting-started/download/

"Compiled CSS and JS
Download ready-to-use compiled code for Bootstrap v4.0.0 to easily drop into your project, which includes:

Compiled and minified CSS bundles (see CSS files comparison)
Compiled and minified JavaScript plugins
This doesn’t include documentation, source files, or any optional JavaScript dependencies (jQuery and Popper.js)."

Download popper.js and place in app/assets/javascripts

cd app/assets/javascripts
wget https://unpkg.com/popper.js/dist/umd/popper.min.js
mv popper.min.js popper.js

The download link is 

https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip

This is what I did:

cd app/assets
wget https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip
unzip bootstrap-4.0.0-dist.zip

jQuery is required by bootstrap. Here is one approach:

cd app/assets/javascripts
wget https://code.jquery.com/jquery-3.3.1.min.js
mv jquery-3.3.1.min.js jquery.js

edit app/assets/application.js

Add
//= require jquery

BEFORE any of the other requires.

rake db:migrate

rails s


bootstrap and javascript

I ended up doing the following:

cd app/assets/javascripts

I downloaded  bootstrap-4.0.0-dist.zip from the bootstrap site.


unzip bootstrap-4.0.0-dist.zip

mv js bootstrap

and then in application.js

Note: simple_form and bootstrap aren't well integrated. I ended up using the simple_form generator only for the input form (_form.html.haml). The simple_form generator is run via the standard rails scaffolding command:

rails g scaffold zip_code  code:string state:references

rails g bootstrap:themed Cities 

and then

rails g scaffold zip_code  code:string state:references

and only overwrite _form.html.haml

I tried running the sample app in production

createdb blog_production

I editted database.yml commenting out username and pasword (matching development)

I had to add to .zshrc

export SECRET_KEY_BASE="adadfakwerwirkkadfj"

then

source ~/.zshrc

and compile assets for production

RAILS_ENV=production bundle exec rake assets:precompile

This didn't work. Seems that I have to install yarn

https://yarnpkg.com/en/docs/install

I followed the instructions and installed yarn on debian.

In production, assets would not load. It seems that rails5 disables static file serving. Edit production.rb and set

config.public_file_server.enabled = true

A typical web app would have this set to false and have apache or nginx serve up static assets.

The twitter-bootstrap-rails adds the static bootstrap files to the asset pipeline.

To add a link to the top of the page, edit app/views/layouts/application.html.haml and
look for 
  %ul.nav.navbar-nav
     %li= link_to "Posts", "/posts"
     %li= link_to "Users", "/users"

Testing: Rails5.1 comes with integration testing built in! It uses capybara. The rails team call this "system testing"

I found it difficult to configure the js and stylesheets. Here is a listing of a working configuration:


.
├── config
│   └── manifest.js
├── images
├── javascripts
│   ├── application.js
│   ├── bootstrap.js
│   ├── cable.js
│   ├── channels
│   ├── jquery.js
│   └── twitter
│       ├── bootstrap.bundle.js
│       ├── bootstrap.bundle.js.map
│       ├── bootstrap.bundle.min.js
│       ├── bootstrap.bundle.min.js.map
│       ├── bootstrap.js
│       ├── bootstrap.js.map
│       ├── bootstrap.min.js
│       └── bootstrap.min.js.map
└── stylesheets
    ├── application.css
    ├── bootstrap_and_overrides.css
    └── scaffolds.scss

6 directories, 16 files
[john@duck:app/assets (master)]$     



