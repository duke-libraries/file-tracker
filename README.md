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
- `LARGE_FILE_THRESHHOLD` - Integer byte size, above which a file is considered "large" for purposes of job queueing (default: 1000000000 [= 1G]).
- `FIXITY_CHECK_PERIOD` - Integer number of days after which fixity should be re-checked (default: 60).
- `BATCH_FIXITY_CHECK_LIMIT` - Integer maximum number of files to submit for fixity checking in a single batch (default: 100000).

See `config/locales/en.yml` for i18n keys.

## Track a directory

Use the rake task:

    rake file_tracker:track[path]

This task will create a `TrackedDirectory` instance and begin inventorying the files under that directory.

Jobs are added to three queues:

    directory
    generate_sha1
    generate_sha1_large (file size > large file threshhold)

New files are discovered by `TrackDirectoryJob` jobs and are eagerly added to the database. File size is calculated
before insertion.

SHA1 digests are generated asynchoronously by `GenerateSHA1Job` jobs. Large files are handled in a separate queue
for the sake of efficiency.

## Fixity checking

To run a batch fixity check for files that are due to be (re-)checked, run:

    rake file_tracker:fixity

Fixity check jobs will be created in two queues:

    check_fixity
    check_fixity_large 

Large files are handled in a separate queue for the sake of efficiency.
