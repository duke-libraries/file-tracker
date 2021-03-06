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

    batch           Batch jobs
    directory       Directory tracking
    file            File tracking
    file_large      Large files
    fixity          Fixity checks
    fixity_large    Fixity checks on large files

Resque pool config is in the usual location `config/resque-pool.yml`.

## Configuration

### Environment

Set variables in `config/application.yml`.  See the `figaro` gem documentation for details.

    BATCH_FIXITY_CHECK_LIMIT   Integer default maximum number of files to submit for fixity checking in a single batch (default: 100000)
    CHECK_LAST_SEEN_PERIOD     Integer window of days outside of which fixity should be checked if not seen (default: 2)
    FILE_TRACKER_DB_PASS       Database user password (required for production)
    FILE_TRACKER_DB_USER       Database user name (default: `file_tracker`)
    FILE_TRACKER_LOG_DIR       Log directory for TrackedFile logger (default: Rails log directory)
    FILE_TRACKER_LOG_SHIFT_AGE Log shift age for TrackedFile logger (default: weekly; see Ruby Logger documentation)
    FIXITY_CHECK_PERIOD        Integer number of days after which fixity should be re-checked (default: 60)
    LARGE_FILE_THRESHHOLD      Integer byte size, above which a file is considered "large" for purposes of job queueing (default: 1000000000 [= 1GB])

### i18n

See `config/locales/en.yml` for i18n keys.

## Inventory

The basic tracking process ("inventory") crawls the tracked directories, queueing up background jobs for each subdirectory and file.  Large files are handled in a separate queue for efficiency (generating digests for very large files can take a long time).

To run the inventory process, execute the task

    rake file_tracker:inventory[:id]

The `[:id]` argument optionally specifies an individual directory to inventory, as opposed to all directories.

## Fixity checking

To run a batch fixity check for files that are due to be (re-)checked, run:

    rake file_tracker:fixity[:max]

The `[:max]` argument is optional and, if present, overrides `BATCH_FIXITY_CHECK_LIMIT`.

A `BatchFixityCheckJob` will be pushed onto the `:batch` queue.
Fixity check jobs will be created in two queues:

    fixity
    fixity_large (file size > large file threshhold)

Large files are handled in a separate queue for the sake of efficiency.
