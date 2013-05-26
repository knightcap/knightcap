source 'https://rubygems.org'


gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'



platforms :jruby do
  # gem 'jdbc-sqlite3'
  gem 'activerecord-jdbc-adapter'
  # gem 'activerecord-jdbcsqlite3-adapter'
  gem 'activerecord-jdbcmysql-adapter'
  gem 'jruby-openssl'
  gem 'jruby-rack-worker', :require => nil
  gem 'therubyrhino', group: :assets
  gem 'warbler'
end

platforms :ruby do
  gem 'sqlite3'
  gem 'mysql2'
end

# Authentication and User Role gems
gem 'devise'
gem 'devise-async'
gem "cancan"

# Exchange Web Services gems
gem 'viewpoint', :git => 'git://github.com/zenchild/Viewpoint.git'

# User Settings gems
gem 'ledermann-rails-settings', :require => 'rails-settings'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'


  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby



  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
end

group :development, :test do
  gem 'rspec-rails'
  # gem for using factories instead of fixtures.
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
end

gem 'jquery-rails'
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
# asynchronous job handling
gem 'delayed_job_active_record'
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'gem rspec-rails, :group => [:test, :development]
