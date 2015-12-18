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
bundle config --delete bin
bundle install
bundle exec spring binstub --all
```
see https://github.com/rails/spring#setup

NB (rails 4 stuff):
> When you install a gem whose executable you want to use in your app,
> generate it and add it to source control:
```
  bundle binstubs some-gem-name
  git add bin/new-executable
```

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
guard
```
runs on http://localhost:3010

### Configuration


## Tests

### setup for testing
```
bundle exec rake db:test:prepare

cp spec/support/focus.rb.disabled spec/support/local_only_focus.rb
```

### run tests
```
script/runtests
```

## Localization File Import API

Supports iOS .strings files, android strings.xml files and a subset of Rails Yaml files (but doesn't support nested
keys).

for setup:

Create a project with a specific name and note the id created (you can use the slug if desired)

To upload a strings file using Curl:

    curl -F file=@/path/to/iphone-app/Project/en.lproj/Localizable.strings -X POST http://localhost:3010/api/projects/:id_or_slug/import/ios
    curl -F file=@/path/to/android-app/Project/res/values-en/strings.xml -X POST http://localhost:3010/api/projects/:id_or_slug/import/android
    curl -F file=@/path/to/rails-app/config/locales/en.yml -X POST http://localhost:3010/api/projects/:id_or_slug/import/yaml

where `/path/to/fieldnotes-iphone-app/FieldNotes/en.lproj/Localizable.strings` is the path to the strings file you
want to upload. Note the `@`, this is important.

TO put in a localization file

     curl -F file=@/path/to/Project/ja.lproj/Localizable.strings -X POST http://localhost:3010/api/projects/:id_or_slug/languages/ja/import/ios
     curl -F file=@/path/to/Project/res/values-ja/strings.xml -X POST http://localhost:3010/api/projects/:id_or_slug/languages/ja/import/android
     curl -F file=@/path/to/Project/config/locales/en.yml -X POST http://localhost:3010/api/projects/:id_or_slug/languages/ja/import/yaml

where ja is the already created language code. Master texts should be created too

## Localization File Export API

Change to the root of the iOS/Android application code and do something like the following:
*iOS*

    export lang=ja
    curl -o ios-project/$lang.lproj/Localizable.strings http://localhost:3010/api/projects/:id_or_slug/export/ios/$lang

iOS .strings files should be UTF-16 LE with BOM. It might be worth ensuring that this is the case using a capable text editor.

*Android*

    export lang=ja
    curl -o android-project/res/values-$lang/strings.xml http://localhost:3010/api/projects/:id_or_slug/export/android/$lang

## Services (job queues, cache servers, search engines, etc.)

## Deployment

Notes for heroku deployment:

### setup:

```
heroku config:set DEVISE_KEY=some-very-long-random-string
heroku config:set DEVISE_EMAIL_FROM=someone@example.com
heroku config:set CANONICAL_HOST=lofi.example.com
heroku config:set CRON_EMAIL_FROM=cron@example.com

heroku addons:add sendgrid:starter
```

Also add scheduled tasks add on with a daily task which runs `rake cron:if_monday` (weekly email)

### Routine deployment

#### Prepare release
```
#update config/initializers/00-version.rb with NEXTVERSION
release prepare -s vLASTVERSION vNEXTVERSION
# review release_notes/vNEXTVERSION and then
git add release_notes/vNEXTVERSION config/initializers/00-version.rb
git commit
```
#### Tag and deploy
```
git push origin master
git tag -a vNEXTVERSION
git push origin vNEXTVERSION
thor heroku:deploy production
```

## Email

To set up mailcatcher (with rvm) locally on your dev environment:

    rvm default@mailcatcher --create do gem install mailcatcher
    rvm wrapper default@mailcatcher --no-prefix mailcatcher catchmail

To view mail sent:

    mailcatcher
    open http://localhost:1080

more info: https://github.com/sj26/mailcatcher


## Markdown.js

We use a pre-compiled version of https://github.com/evilstreak/markdown-js (Thanks!). For reference we generated it with the following

```
git clone evilstreak/markdown-js && cd markdown-js && npm install
./node_modules/.bin/grunt all --force
cp dist/markdown.js ../lofi-lions/vendor/assets/javascripts/markdown.js
```

# License

This project is open-sourced under the Apache 2.0 license. See LICENSE.TXT
