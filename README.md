# file-tracker

A simple application for tracking files in directories. :)

## Requirements

- Ruby 2.4+
- Rails 5

See https://github.com/duke-libraries/file-tracker/wiki/Dependencies
for production implementation details using RVM, Passenger/Apache, Resque/Redis, and MySQL.

## Database

MySQL database creation:

    create database file_tracker default character set 'utf8';
    create user 'file_tracker'@'localhost' identified by '********';
    grant all on file_tracker.* to 'file_tracker'@'localhost';
    flush privileges;

## Job queues

- children (recursive directory inventory)
- file
- large_file (for files larger than LARGE_FILE_THRESHHOLD)
- fixity

Resque pool config is in the usual location `config/resque-pool.yml`.

## Configuration

Set variables in `config/application.yml`.  See the `figaro` gem documentation for details.

- `FILE_TRACKER_DB_USER` - Database user name (default: `file_tracker`)
- `FILE_TRACKER_DB_PASS` - Database user password (required for production)
- `LARGE_FILE_THRESHHOLD` - Integer byte size, above which a file is considered "large" for purposes of job queueing (default: 1G).

See `config/locales/en.yml` for i18n keys.

## Track a directory

Use the rake task:

    rake file_tracker:track[path]

This task will create a `TrackedDirectory` instance and begin inventorying the files under that directory.