# file-tracker

A Rails application for tracking files in directories.

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

    inventory       Recursive directory inventory
    duracloud       DuraCloud replication checks
    batch           Batch jobs which queue up other jobs (should only need 1 worker)
    fixity          Fixity checks
    fixity_large    Fixity checks on large files
    digest          SHA1 and MD5 digest generation
    digest_large    SHA1 and MD5 digest generation for large files

Resque pool config is in the usual location `config/resque-pool.yml`.

## Configuration

### Environment

Set variables in `config/application.yml`.  See the `figaro` gem documentation for details.

    FILE_TRACKER_DB_USER       Database user name (default: `file_tracker`)
    FILE_TRACKER_DB_PASS       Database user password (required for production)
    LARGE_FILE_THRESHHOLD      Integer byte size, above which a file is considered "large" for purposes of job queueing (default: 1000000000 [= 1G]).
    FIXITY_CHECK_PERIOD        Integer number of days after which fixity should be re-checked (default: 60).
    BATCH_FIXITY_CHECK_LIMIT   Integer default maximum number of files to submit for fixity checking in a single batch (default: 100000).

See [duracloud-client](https://github.com/duracloud/duracloud-ruby-client) documentation for detailed information on configuration of DuraCloud settings.

### i18n

See `config/locales/en.yml` for i18n keys.

## Track a directory

After a new `TrackedDirectory` instance is created (persisted), a process will automatically inventory the files under that directory.

Jobs are added to three queues:

    inventory
    digest
    digest_large (file size > large file threshhold)

New files are discovered by `TrackDirectoryJob` jobs and are eagerly added to the database. File size is calculated
before insertion.

SHA1 digests are generated asynchoronously by `GenerateDigestJob` jobs. Large files are handled in a separate queue
for the sake of efficiency.

## Fixity checking

To run a batch fixity check for files that are due to be (re-)checked, run:

    rake file_tracker:fixity[:max]

The `[:max]` argument is optional and, if present, overrides `BATCH_FIXITY_CHECK_LIMIT`.

A `BatchFixityCheckJob` will be pushed onto the `:batch` queue.
Fixity check jobs will be created in two queues:

    fixity
    fixity_large (file size > large file threshhold)

Large files are handled in a separate queue for the sake of efficiency.

## Possible Enhancements

- Listener(s) based on the [listen](https://github.com/guard/listen) gem.
