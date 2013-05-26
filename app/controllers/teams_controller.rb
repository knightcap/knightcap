class TeamsController < ApplicationController
  before_filter :authenticate_user!
  # this helper_method call is required in order to register the helper methods.
  helper_method(:sort_column, :sort_direction)
  
  # Method for reading teams with current user.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def index
    @teams = current_user.teams.where("role = ?", :member)
    @adminTeams = current_user.teams.where("role = ?", :admin)
    respond_to do |format|
      format.html # index.html.erb
      #format.json { render json: @teams }
    end
  end

  # Redirect to show page of specific team
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def show
    @team = Team.find(params[:id])
    @tags = User.all.map(&:email)
 
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @team }
    end
  end

  # Method for creating a new team.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def new
    @team = Team.new
    # This origin call comes from the requesting page that the new Team request came from (Services or Teams controller).
    # A request from services means an origin param will exist. will default to the controller param if origin doesn't exist.
    # Controller param *should* be the teams controller, thus making origin teams in that instance.
    @origin = params[:origin] || params[:controller]
    @buttonvalue = "create team"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @team }
    end
  end

  # Method for determining whether a user can edit the team.
  # If current user is not the admin,show an error message.
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def edit
    @team = Team.find(params[:id])
    @buttonvalue = "update team"
    if !is_team_admin(@team)
      redirect_to teams_path, alert: "You do not have the privileges required to edit this team."
    end
  end

  # Creating new team with different call origin.
  # Associated team will be set automatically on new service page 
  # if the create team request comes from services page.
  # Otherwise it will redirect to teams index if the request comes from teams page
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def create
    # This line determines whether the original create team request came from a services or teams and sets up the redirect accordingly
    origin_redirect = params[:team][:origin] == 'services'? new_service_path : teams_path
    
    # Removes the :origin key/value from the params as is not part of saving the model
    params[:team].delete :origin
    @team = Team.new(params[:team])
    @buttonvalue = "create team"
    
    respond_to do |format|
      if @team.save
        current_user.teamsusers.create!(:team_id => @team.id, :role => 'admin')
        format.html { redirect_to origin_redirect + "?myTeam=" + @team.id.to_s, notice: 'Your team has been successfully created.' }
        format.json { render json: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end


  # Update team name with requried privileges, otherwise show an error message
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def update
    @team = Team.find(params[:id])
    @buttonvalue = "update team"
    
    if is_team_admin(@team)
    params[:team].delete :origin
    
      respond_to do |format|
        if @team.update_attributes(params[:team])
          format.html { redirect_to @team, notice: 'Your team has been successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @team.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to teams_path, alert: "You do not have the privileges required to edit this team."
    end
  end

  # Destroying team 
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def destroy
    @team = Team.find(params[:id])
    if is_team_admin(@team)
      @team.destroy
    end
    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end

  # Change role of a team member.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #    
  def changeRole
    user = User.find(params["member"])
    
    newRole = user.teamsusers.find_by_team_id(params["team"]).role == "member" ? "admin" : "member"
    user.teamsusers.find_by_team_id(params["id"]).update_attributes(:role => newRole)
    @team = Team.find(params["id"])
    
    respond_to do |format|
      format.html {render :layout=>false}
      format.json { head :no_content }
    end
   end

  # Add new team member to this team with default role 'member'.
  # If email address is invalid,error message should be returned.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #  
   def addMember
   @user = User.find_by_email(params['email'])
   @team = Team.find(params[:id])
   
    if @user.nil?
      error="The user does not exist"
    else
      user_id = @user.id
      if Teamsuser.exists?(:user_id=>user_id,:team_id=>params['id'])
        error="The user is already in this team"
        else
          team_id = params['id']
          newMember =Teamsuser.create(:user_id=> user_id,:team_id=>team_id,:role=>"member")
        end
    end
    
    flash.now[:alert] = error
    respond_to do |format|
      format.html {render :layout=>false}
      format.json { head :no_content }
    end
  end
 
  # Delete a team member from this team.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def deleteMember
    user = User.find(params['member'])   
    team_id = params['id']
    @team = Team.find(team_id)
    Teamsuser.destroy_all(:user_id=>user,:team_id=>team_id)
    
    respond_to do |format|
      format.html {render :layout=>false}
      format.json { head :no_content }
    end
    
  end
  
  private
  # sort_column & sort_direction are private helper methods for setting current sortable column, and sort directon
  # prevents SQL injection by checking user input and providing safe defaults.
  def sort_column
    Service.column_names.include?(params[:sort])? params[:sort] : "name"
  end

  def sort_direction
   %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  # Private method for determining whether a user is admin of a team.
  #
  # * *Arguments*    :
  #   - +team+ -> The team to test admin privileges on
  # * *Returns* :
  #   - Boolean
  #
  def is_team_admin(team)
    return !(team.users.where("users.id = ? AND role = ?", current_user.id, :admin)).empty?
  end
end
