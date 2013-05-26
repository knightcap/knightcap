class SettingsController < ApplicationController
  # Devise before filter
  before_filter :authenticate_user!
  
  # Renders settings index page and displays admin role settings and member role settings accordingly
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def index
    # role? method on user is defined in User model
    @teams = Team.all if current_user.role? :admin
    @roles = Usergroup.all if current_user.role? :admin
    @default_role = Usergroup.find_by_name(:team_member.to_s.camelize).id if current_user.role? :admin
    @gblist = Globalblist.all

    # add new users to app - site admin role only
    if params[:new_user_email].present?
      if User.find_by_email(params[:new_user_email]).present?
        flash.now[:alert] = "User " + params[:new_user_email] + " already exists."
      else
    
        begin
          email = params[:new_user_email]
          password = generatePassword()
          role_id = params[:new_user_role]
          team_id = params[:new_user_team] if params[:new_user_team].present?
          user = User.create(:email => email, :password => password, :password_confirmation => password)
          user.roles.build(:usergroup => Usergroup.find_by_id(role_id)).save
          if team_id.present?
            user.teamsusers.build(:team_id => team_id).save
          end
          url = "#{request.protocol}#{request.host_with_port}"
          Mailer.delay.newUserEmail(email, password, url)
          flash.now[:notice] = "User " + email = params[:new_user_email] + " successfully created."

        rescue
          flash.now[:alert] = "Error creating user, contact admin. Oh wait... that's you! Awkward..."
        end
      end
      
    end
    @params = params
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @settings }
    end
  end

  # Method to swap widgets
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def swapWidget
    x = Array.new
    x = [current_user.settings(:widgets).list[0],current_user.settings(:widgets).list[1],current_user.settings(:widgets).list[2]]
    newWidget = Widget.getWidgetByName(params[:name])
    newWidget.step = params[:step]
    x[params[:index].to_i] = newWidget
    
    current_user.settings(:widgets).update_attributes! :list => x
    
    respond_to do |format|
      format.html { render :layout=>false }
      format.json { render json: @settings }
    end
  end
  
  # Controller for the global blacklist index page
  #
  # * *Args*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def gblistIndex
    if admin_setting
      return
    end
    @gblist = Globalblist.all

    respond_to do |format|
      format.html
      format.json { head :no_content }
    end
  end

  
  # Add a single email to the global blacklist
  #
  # * *Args*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def gblistAdd
    if admin_setting
      return
    end
    email = params[:email]
    
    if emailRegex(email)
      entry = Globalblist.find_by_email(email)
      if !entry.nil?
        redirect_to :gblist, alert: "The email address you are trying to add already exists in the blacklist."
        return
      else
        Globalblist.create(:email => email)
      end
    end

    respond_to do |format|
      format.html { redirect_to :gblist }
      format.json { head :no_content }
    end
  end
    
  # Parse a csv file and add all valid emails to the global blacklist
  #
  # * *Args*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def gblistAddCsv
    if admin_setting
      return
    end
    if (!params[:csvfile].nil?)
      emailString = params[:csvfile].read
      emails = emailString.split(',').map(&:strip)
      
      for email in emails do
        if emailRegex(email)
          entry = Globalblist.find_by_email(email)
          if entry.nil?
            Globalblist.create(:email => email)
          end
        end
      end
  
      respond_to do |format|
        format.html { redirect_to :gblist }
        format.json { head :no_content }
      end 
    else
      redirect_to :gblist, :alert => "There was an error while trying to process your CSV file."
    end
  end
  
  
  
  # Remove a single email from the global blacklist
  #
  # * *Args*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def gblistRemove
    if admin_setting
      return
    end
    email = (params[:email])
    entry = Globalblist.find_by_email(email)
    if !entry.nil?
      entry.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to :gblist }
      format.json { head :no_content }
    end
  end
  
  
  
  private
  
  # Private method to generate a password with 8 random characters from 'a' to 'z;
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - String of randomly generated password
  #
  def generatePassword
    ('a'..'z').to_a.shuffle[0,8].join
  end
  
  # Checks that the email address is a valid email address
  #
  # * *Args*    :
  #   - email -> An email address (string)
  # * *Returns* :
  #   - index of the first match (int) or nil
  #
  def emailRegex(email) 
    email =~ /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
  end
  
  def admin_setting
    if !current_user.role?("Admin")
      redirect_to services_path, :alert => "You do not have the privileges required to view this page."
      return true
    end
  end
end
