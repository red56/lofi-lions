# LoFi  Localization Server

This project will allow you to create a server to help you manage localization of in a very low-fi way. (there are very advanced management software and services for Translation agencies to use. This is much more low maintenance).

Here are the aims of the project:

* You can create a project with a set of "master" texts (in whatever language you like), with a machine-readable identifier, a comment, and master (English) text
* You can create as many languages as you like for that project
* Add/Invite people by email address to login and translate one or more languages
* Define fallbacks for missing translations (e.g. another language/locale)
* Mark local translations as needing review when the master has been altered
* Download files in certain formats:
    * android,
    * iOS
    * django / gettext (.po)
    * rails (.yml)
* make subsets of this project with one or more texts included
* Translator assistance: be able to download / upload CSV of translations rather than have


The rest of this doc is about how to develop and install it locally. The software is written in Ruby (2.0) and Ruby-on-Rails (v4.0). You'll need to know these two to carry on.

## Setup development machine

### install / system dependencies
install postgres
*get the git repo, ensure right ruby, bundler... then: *
```
bundle install
bundle exec spring binstub --all
```
see https://github.com/rails/spring#setup


#### setup db
```
cp config/database.template.yml config/database.yml
psql -c "CREATE USER lofi_lions WITH CREATEDB; ALTER USER lofi_lions WITH PASSWORD NULL;"
bundle exec rake db:setup
bundle exec rake db:test:prepare
```

### get some decent data

### server

```
bundle exec guard -i
#for live reload
script/serve -s
```
runs on http://localhost:3007

### Configuration


## Tests

### setup for testing
```
bundle exec rake db:test:prepare

cp spec/support/focus.rb.disabled spec/support/local_only_focus.rb
```

### run tests
```
rspec
```

## Localization File Import API

Only supports iOS .strings files at present.

To upload a strings file using Curl:

    curl -F file=@/path/to/fieldnotes-iphone-app/FieldNotes/en.lproj/Localizable.strings -X POST http://localhost:3000/import/ios

where `/path/to/fieldnotes-iphone-app/FieldNotes/en.lproj/Localizable.strings` is the path to the strings file you want to upload.
Note the `@`, this is important.


## Services (job queues, cache servers, search engines, etc.)

## Deployment

to deploy on heroku:

```
heroku config:set DEVISE_KEY=some-very-long-random-string
heroku config:set DEVISE_EMAIL_FROM=someone@example.com
heroku config:set CANONICAL_HOST=lofi.example.com
```

# License

This project is open-sourced under the Apache 2.0 license. See LICENSE.TXT