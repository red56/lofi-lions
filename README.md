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

NB: There are some limitations:

* Master text is in English. (To change this would require thinking more seriously about plurals in Master text and how to display them for localization).
* Android should not use string_array. Android also doesn't use html formatting within texts.
* We use a particular library for iphone plural strings
* no .po or .yml yet
* you need to define the pluralization defaults for each language.

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

Supports iOS .strings files and android strings.xml files.

for setup:

To upload a strings file using Curl:

    curl -F file=@/path/to/iphone-app/Project/en.lproj/Localizable.strings -X POST http://localhost:3000/import/ios
    curl -F file=@/path/to/android-app/Project/res/values-en/strings.xml -X POST http://localhost:3000/import/android

where `/path/to/fieldnotes-iphone-app/FieldNotes/en.lproj/Localizable.strings` is the path to the strings file you want to upload.
Note the `@`, this is important.

TO put in a localization file

     curl -F file=@/path/to/Project/ja.lproj/Localizable.strings -X POST http://localhost:3007/languages/ja/import/ios
     curl -F file=@/path/to/Project/res/values-ja/strings.xml -X POST http://localhost:3007/languages/ja/import/android
     #or
     thor ios:localizations ja < /path/to/Localizable.strings
     thor android:localizations ja < /path/to/strings.xml


where ja is the already created language code. Master texts should be created too

## Services (job queues, cache servers, search engines, etc.)

## Deployment

Notes for heroku deployment:

### setup:

```
heroku config:set DEVISE_KEY=some-very-long-random-string
heroku config:set DEVISE_EMAIL_FROM=someone@example.com
heroku config:set CANONICAL_HOST=lofi.example.com

heroku addons:add sendgrid:starter
```

### Routine deployment

```
git push heroku master
heroku run rake db:migrate

```

# License

This project is open-sourced under the Apache 2.0 license. See LICENSE.TXT