class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :rememberable, :recoverable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable, :trackable, :validatable, :recoverable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :team_id
  # attr_accessible :title, :body

  #belongs_to :team
  
  has_settings do |s|
      s.key :dashboard, :defaults => { :theme => 'blue', :view => 'monthly', :filter => false }
      s.key :widgets, :defaults => { :list => [Widget.responses, Widget.promoters, Widget.detractors] }
    end
  
  
  # Usergroups and roles are reserved for site-wide access privelages.
  has_many :roles
  has_many :usergroups, :through => :roles

  
  # This is the M2M relationship for sharing services with individual users as a one off.
  has_many :servicesusers
  has_many :services, :through => :servicesusers
  
  has_many :teamsusers
  has_many :teams, :through => :teamsusers


  # Method to determine current role (usergroup) for user. assumes that roles are stored in camelCase in the database
  # 'rails' way of inputting search string is as underscored syntax like so -> :super_admin
  # underscored version used on the models/ability.rb cancan abilities file.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def role?(role)
    return !!self.usergroups.find_by_name(role.to_s.camelize)
  end

end
