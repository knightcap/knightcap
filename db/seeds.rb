# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



    #ug_user = Usergroup.find_or_create_by_name(:name => "User")
    ug_admin = Usergroup.find_or_create_by_name(:name => "Admin")
    ug_teamleader = Usergroup.find_or_create_by_name(:name => "TeamLeader")
    ug_teammember = Usergroup.find_or_create_by_name(:name => "TeamMember")
    
#to be taken out during deployment
 t_itsupport = Team.find_or_create_by_name(:name => "IT Support")
 t_forex = Team.find_or_create_by_name(:name => "Foreign Exchange")
 t_invbank = Team.find_or_create_by_name(:name => "Investment Banking")
 t_custsupp = Team.find_or_create_by_name(:name => "Customer Support")
 
u_admin = User.find_or_create_by_email(:email => "admin@suncorp.com", :password => "111111", :password_confirmation => "111111")
u_admin.roles.build(:usergroup => Usergroup.find_by_name("Admin")).save

u_admin = User.find_or_create_by_email(:email => "admin@suncorp.com", :password => "111111", :password_confirmation => "111111")
u_admin.roles.build(:usergroup => Usergroup.find_by_name("Admin")).save 

u_jimmy = User.find_or_create_by_email(:email => "jimmy@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_itsupport.id, :user_id => u_jimmy.id, :role => 'admin')
Teamsuser.create(:team_id => t_custsupp.id, :user_id => u_jimmy.id)

u_tom = User.find_or_create_by_email(:email => "tom@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_itsupport.id, :user_id => u_tom.id)

u_lau = User.find_or_create_by_email(:email => "lau@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_forex.id, :user_id => u_lau.id)

u_davy = User.find_or_create_by_email(:email => "davy@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_forex.id, :user_id => u_davy.id)
Teamsuser.create(:team_id => t_itsupport.id, :user_id => u_davy.id, :role => 'admin')

u_marwan = User.find_or_create_by_email(:email => "marwan@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_invbank.id, :user_id => u_marwan.id)

u_sharde = User.find_or_create_by_email(:email => "sharde@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_invbank.id, :user_id => u_sharde.id)

u_britta = t_custsupp.users.find_or_create_by_email(:email => "britta@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_custsupp.id, :user_id => u_britta.id)

u_chris = User.find_or_create_by_email(:email => "chris@suncorp.com", :password => "111111", :password_confirmation => "111111")
Teamsuser.create(:team_id => t_custsupp.id, :user_id => u_chris.id)

# Admin
#Set up under admin user above.

# Team Leaders
ug_teamleader.users << u_jimmy
ug_teamleader.users << u_lau
ug_teamleader.users << u_marwan
ug_teamleader.users << u_britta

# Team Members
ug_teammember.users << u_jimmy
ug_teammember.users << u_tom
ug_teammember.users << u_lau
ug_teammember.users << u_davy
ug_teammember.users << u_marwan
ug_teammember.users << u_sharde
ug_teammember.users << u_britta
ug_teammember.users << u_chris

Service.delete_all
s_helpdesk = t_itsupport.services.find_or_create_by_name(:name => "Helpdesk Support", :email_content => "Let us know how our helpdesk is doing!")

s_charts = Service.find_or_create_by_name(:name => "Charting Tool",
                        :email_content => "Rate our charting tool",
                        :team_id => t_forex.id)

s_subversion = t_custsupp.services.find_or_create_by_name(:name => "Subversion", :email_content => "Let us know how Subversion is doing!")
         
Dlist.delete_all               
dl_jimmy = s_helpdesk.dlists.find_or_create_by_email(:email => "jimmy@suncorp.com")
dl_tom = s_helpdesk.dlists.find_or_create_by_email(:email => "tom@suncorp.com")
dl_lau = s_helpdesk.dlists.find_or_create_by_email(:email => "lau@suncorp.com")

Blist.delete_all               
bl_tom = s_helpdesk.blists.find_or_create_by_email(:email => "tom@suncorp.com")


Survey.delete_all               
sur_help1 = s_helpdesk.surveys.create()

Result.delete_all

for i in 0..5 do
  
r1= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 10, :comments => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do");
r2= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 10, :comments => "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut");
r3= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 6, :comments => "enim ad minim veniam, quis nostrud exercitation ullamco laboris");
r4= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in");
r5= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla");
r1.created_at = (i*30).days.ago
r2.created_at = (i*30).days.ago
r3.created_at = (i*30).days.ago
r4.created_at = (i*30).days.ago
r5.created_at = (i*30).days.ago
r1.updated_at = (i*30).days.ago
r2.updated_at = (i*30).days.ago
r3.updated_at = (i*30).days.ago
r4.updated_at = (i*30).days.ago
r5.updated_at = (i*30).days.ago

r1.save!
r2.save!
r3.save!
r4.save!
r5.save!

if i > 3
  r6= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "pariatur. Excepteur sint occaecat cupidatat non proident, sunt ");
  r7= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "in culpa qui officia deserunt mollit anim id est laborum.");
  r8=sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do");
  r9=sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut");
  r10= sur_help1.results.create(:email => "tester@suncorp.com", :done =>true, :score => 9, :comments => "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut");
  
  r6.created_at = (i*30).days.ago
  r7.created_at = (i*30).days.ago
  r8.created_at = (i*30).days.ago
  r9.created_at = (i*30).days.ago
  r10.created_at = (i*30).days.ago
  
  r6.updated_at = (i*30).days.ago
  r7.updated_at = (i*30).days.ago
  r8.updated_at = (i*30).days.ago
  r9.updated_at = (i*30).days.ago
  r10.updated_at = (i*30).days.ago
    
  r6.save!
  r7.save!
  r8.save!
  r9.save!
  r10.save!
end

end

# This line is for the has_many :through relationship
Servicesuser.create(:service => s_charts, :user => u_jimmy)
