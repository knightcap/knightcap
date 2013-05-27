knightcap
=========

The Net Promoter Score Survey Application


Software Requirements
---------------------

* A Unix box
* Ruby Version Manager (optional, but highly recommended)
* Ruby >= v1.9.3 OR
* JRuby, >= v1.7.4
* Tomcat OR
* Passenger
* Apache (optional)
* Java Runtime Environment (if using Tomcat)
* MySQL

Installation
------------

:knightcap can be run on either Tomcat (Java) or Passenger (vanilla Ruby) web servers. These servers can be found in standalone variants, or as add-ons to the Apache web server.

Regardless of which version of ruby you choose to run, the best way to manage your Ruby installations is by using Ruby Version Manager (RVM). Shell access to RVM is with the keyword ‘rvm’ – however RVM must be installed first as such. On Ubuntu, run the following commands in the Terminal:

				$ sudo apt-get update
				// Install curl if needed
				$ sudo apt-get install curl
				// Use curl to install RVM
				$ \curl -L https://get.rvm.io | bash -s stable
				// Load RVM
				$ source ~/.rvm/scripts/rvm
				// tell RVM to install any dependancies
				$ rvm requirements
				// install vanilla Ruby v1.9.3
				$ rvm install 1.9.3 
				// if using JRuby
				$ rvm install jruby
				// set default ruby (change to jruby if using that)
				$ rvm use 1.9.3 --default

Vanila Ruby
-----------

If running under vanilla Ruby, the process is as follows: 

1.	Install Apache and/or Passenger as per their instructions on their websites (these can change, so best not to hard code the legacy methods).
2.	Install the MySQL server using the command `sudo apt-get install mysql-server`
3.	 Clone the application from the repository at https://github.com/knightcap/knightcap - (you're already here!)
4.	navigate to the top folder of knightcap in the terminal, and run the command `bundle install` inside that folder. This will install all of the required gems for your system.
5.	Setup the app by changing the database.example.yaml to database.yaml, and configure user, password and database settings inside. For production, only the production settings are necessary. The above file is located in `config/”`
6.	Change the name of the application.example.yaml file to application.yaml, and configure the settings inside. The above file is located in `config/`.
7.	Create the required user(s) and database(s) in MySQL, Don’t worry about the tables, we will do that in the next step.
8.	From within terminal, and in the root of the application, run the command `rake db:migrate RAILS_ENV=production` this will populate your production database with the correct tables, attributes, and associations.
9.	Precompile the assets with the command `RAILS_ENV=production bundle exec rake assets:precompile` this minifies JavaScript and CSS, and prepares images to be viewable in production mode.
10.	Lastly, follow your chosen version of Passenger’s rails app deployment guide and turn on the server.


Tomcat and JRuby
----------------

If running under JRuby, the process is as follows: 

1.	Install Apache and/or Tomcat as per their instructions on their websites (these can change, so best not to hard code the legacy methods).
2.	Install the MySQL server using the command `sudo apt-get install mysql-server`
3.	 Clone the application from the repository at https://github.com/knightcap/knightcap - (you're already here!)
4.	run the command `jruby –S gem install jruby-openssl`
5.	navigate to the top folder of knightcap in the terminal, and run the command “bundle install” inside that folder. This will install all of the required gems for your system.
6.	Setup the app by changing the database.example.yaml to database.yaml, and configure user, password and database settings inside. For production, only the production settings are necessary. The above file is located in `config/`.
7.	Change the name of the application.example.yaml file to application.yaml, and configure the settings inside. The above file is located in `config/`.
8.	Create the required user(s) and database(s) in MySQL, Don’t worry about the tables, we will do that in the next step.
9.	From within terminal, and in the root of the application, run the command `rake db:migrate RAILS_ENV=production` this will populate your production database with the correct tables, attributes, and associations.
10.	Precompile the assets with the command `RAILS_ENV=production bundle exec rake assets:precompile` this minifies JavaScript and CSS, and prepares images to be viewable in production mode.
11.	Run the command `warble`. This will bundle the app into a .war file, which can be easily deployed into Tomcat.
12.	Copy the above .war file into your chosen location on the Tomcat server, usually somewhere in webapps/.


Local Documentation
-------------------

There is also the ability to generate a local version of the application documentation by running the command `rake rdoc`. This will generate the documentation in `root_application_folder/html`. This document contains further information on the classes and their methods.


Maintenance
-----------

At an absolute minimum, ensure that the rails gem and its dependencies are at the latest supported version. Ruby 2 and Rails 4 are in beta stages, and it isn’t ise to upgrade to them at this point, that move may break the application. It is also a good idea to keep the database backed up. Lastly, continue to maintain your servers as you currently do.


FAQ
---

Vanila Ruby

Q: I cannot install the mysql2 gem
A: This may seem obvious, however ensure that you have the MySQL server installed before you attempt to install the mysql2 gem.


Q: I am getting errors when trying to run the application using Windows
A: There is a known bug with ruby on windows. Go to the Gemfile, and remove the part that says `platform :ruby do --- end` place those gems outside of the block.  



Jruby

Q: I keep on getting out of memory exceptions when deploying :knightcap.
A: Most likely there is not enough memory allocated to Tomcat. On a linux machine this variable can be changed at location `/etc/default/tomcat7` Change the JAVA_OPTS line to something like the following: 

`JAVA_OPTS="-Djava.awt.headless=true -Xmx2048m -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode"`

the section `-Xmx2048m` is the amount of memory (in mb) allocated to Tomcat, the above example is 2gb. A good minimum to use is 512mb.


