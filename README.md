# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

  ruby 2.6.6

* Rails version

  rails 6.1.5

* System dependencies
  
  The main gems used in the project are:

  (Aldous Gem)[https://github.com/envato/aldous]
  The basic idea behind this gem is that Rails is missing a few key things that make our lives especially painful when our applications start getting bigger and more complex.

  Gems for test and coverage
  * (factory_bot_rails Gem)[https://github.com/thoughtbot/factory_bot_rails] 
  * (rspec-rails Gem)[https://github.com/rspec/rspec-rails] 
  * (database_cleaner-active_record Gem)[https://github.com/DatabaseCleaner/database_cleaner-active_record] 
  * (simplecov Gem)[https://github.com/simplecov-ruby/simplecov] 
  
Follow the next deployment instructions in the follow order:

  1. Install gems
    
     ```
     bundle install
  2. Database creation (used postgresql)
     1. Copy and paste the file .env.example to .env in the root project
     2. Edit file .env with your access of databases (host, port, username, password, timeout, db dev, db test)
     3. execute the follow instructions:
        ```
        rails db:create
        rails db:migrate
        rails db:seed
     4. Optional instruction: to replicate the same exercise of the test technical, run the follow commands:
        ```
        rails db:seed:exercise
     
  3. Run the test suite
  
      ```
      bundle exec rspec spec

  4. Review the code coverage generated in the folder /coverage/index.html 
