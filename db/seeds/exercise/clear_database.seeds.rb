require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:truncation)