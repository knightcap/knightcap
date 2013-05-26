#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

SuncorpNpsApp::Application.load_tasks

RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.rdoc"

  rdoc.rdoc_files.include("README.rdoc", "doc/*.rdoc", "app/controllers/*.rb","app/helpers/*.rb", "lib/*.rb", "app/controllers/**/*.rb")
  #rdoc.rdoc_files.exclude("app/models/*.rb")
  rdoc.rdoc_files.include("app/models/user.rb", "app/models/widget.rb")
  rdoc.rdoc_files.include("config/initializers/common_words.rb")
  rdoc.rdoc_files.exclude("app/controllers/application_controller.rb")
  #change above to fit needs

  rdoc.title = "App Documentation"
  rdoc.options << "--all"
end
