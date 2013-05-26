class ServicesController < ApplicationController
  # Devise before filter
  before_filter :authenticate_user!
  # this helper_method call is required in order to register the helper methods.
  helper_method(:sort_column, :sort_direction)
  
  include ReportsHelper
  include ServicesHelper
  include WidgetsHelper
  include ApplicationHelper

  # Exchange Web Services Interface - lib/ews.rb
  require_dependency 'ews'
  include Ews
  
  # Shows all services which belongs to the team which the users belong in by saving them into @teamServices
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def index
    #@teamServices = Service.where('team_id = ?', current_user.team_id).order(sort_column + " " + sort_direction)
    teams = Team.joins(:users).where("user_id = ?", current_user.id)    
    @teamServices = Service.joins(:team).where(:team_id => teams).order(sort_column + " " + sort_direction)
    @otherServices = Service.joins(:users).where('user_id = ?', current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @services }
    end  
  end

  # Show service details and handle EWS inputs.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def show 
    #caching Service.find(params[:id])
    s = Service.find(params[:id])
    
    #check if service shared with current user
    temp = Service.joins(:users).where('user_id = ?', current_user.id).limit(1).first
    temp_teams = Team.joins(:users).where("user_id = ?", current_user.id)
    temp_arr = []
    temp_teams.each do |t|
      temp_arr.push(t.id)
    end
    #if it's not shared AND does not belong to his team, redirect
    if !checkService(s)
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      #otherwise, display service
      @service = s

      # flags to assist with correct email folder display
      @no_folder = nil
      @choose_folder = nil
      @have_folder = nil

      # If no folder record exists, set no_folder flag to true, otherwise set have_folder to the folder name
      ews_folder = Servicesuser.where("service_id = ? AND user_id = ?" , params[:id], current_user.id).limit(1).first
      if ews_folder.nil?
        @no_folder = true
      else
        @have_folder = ews_folder.ews_name
      end

      # If a user has attemnpted to login to change a exchange folder enter this branch
      if params[:user_name].present? || params[:password].present?
        begin
          @ews_folders = getFolders(params[:user_name], params[:password]) #method from Ews module, loads Hash{id=>folderName}
          flash[:ews_folders] = @ews_folders
          if ews_folder.nil?
            @ewsID = 0 #ewsID is the default select_box item to show. has a blank default at index 0
          else
            @ewsID = ews_folder.ews_id
          end
          @choose_folder = true
          flash.now[:notice] = "Your Exchange Login was successful. Please select a folder from the list below."
        rescue
          @choose_folder = false # Just incase it was set to true above...
          flash.now[:alert] = "The Exchange username/password entered is incorrect. Please try again."
        end
      end

      # Triggers this branch if a change of folder request has come through
      # :ews_select is the ID of the select box
      if params[:ews_select].present?
        if ews_folder.nil?
          new_ews = Servicesuser.new(:service_id => params[:id], :user_id => current_user.id, :ews_id => params[:ews_select], :ews_name => flash[:ews_folders][params[:ews_select]])
          new_ews.save
          @have_folder = new_ews.ews_name
          flash.now[:notice] = "Your monitored Exchange folder has been successfully changed."

        elsif params[:ews_select] != ews_folder.ews_id
          ews_folder.update_attribute(:ews_id, params[:ews_select])
          ews_folder.update_attribute(:ews_name, flash[:ews_folders][params[:ews_select]])
          @have_folder = ews_folder.ews_name  
          flash.now[:notice] = "Your monitored Exchange folder has been successfully changed."
        end
      end
      
      #show all users not shared the service
      @team = @service.team
      
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service }
      end
    end
  end

  # Renders a new service page with default team value set if the user has just created a team
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def new
    @service = Service.new
    @teams = current_user.teams.where('role = ?', 'admin')
    @myTeam = params[:myTeam]
    @buttonvalue = "create service"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service }
    end
  end

  # Renders edit service page. Redirect user if he is not a admin of the team.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def edit
    @service = Service.find(params[:id])
    if !checkServiceAdmin(@service)
      redirect_to services_path, alert: "You do not have the privileges required to edit this team."
    else
      @teams = current_user.teams.where('role = ?', 'admin')
      @buttonvalue = "update service"
      @myTeam = params[:myTeam]
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service }
      end
    end
  end

  # Creates a service and set its team.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def create
    @service = Service.new(params[:service])
    # passing teams to create in case service name left blank, required for 'new' action to reload from here
    @teams = current_user.teams.where('role = ?', 'admin')
    @buttonvalue = "create service"

    respond_to do |format|
      if @service.save
        format.html { redirect_to :services, notice: 'Your service has been successfully created.' }
        format.json { render json: @service, status: :created, location: @service }
      else
        format.html { render action: "new" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end


  # Update service information if user is an admin
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def update
    @service = Service.find(params[:id])
    @buttonvalue = "update service"
    
    respond_to do |format|
      if checkServiceAdmin(@service) && @service.update_attributes(params[:service])
        format.html { redirect_to @service, notice: 'Your service has been successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes a service if user is an admin
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def destroy
    @service = Service.find(params[:id])
    
    if checkServiceAdmin(@service)
      @service.destroy
      respond_to do |format|
        format.html { redirect_to services_url }
        format.json { head :no_content }
      end
    else
      redirect_to services_path, alert: "You do not have the privileges required to delete this team."
    end
  end
  
  # Generates a report from 5 months ago till now in months.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def report
    @service = Service.find(params[:id])
    
    if !checkService(@service)
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      @date = Hash.new
      @date["start"] = DateTime.now - 5.months
      @date["end"] = DateTime.now
      @date["step"] = "Months"
      
      respond_to do |format|
        format.html # report.html.erb
        format.json { render json: @service }
      end
    end
  end
  
  # Generate a new report depending on the start date, end date, and step.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def reportSubmit  
    @date = Hash.new
    @service = Service.find(params[:id])
    if !checkService(@service)
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      @date["start"] = Date.new(params[:syr].to_i, params[:smth].to_i, params[:sday].to_i)
      @date["end"] = Date.new(params[:eyr].to_i, params[:emth].to_i, params[:eday].to_i)
      @date["step"] = params[:step]
      @service = Service.find(params[:id])
      respond_to do |format|
        format.html {render :layout=>false}
        format.json { render json: @service }
      end
    end
  end

  # Generate a pdf with PDFKit using template 'pdf.html.erb' and css file 'pdf.css'
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
 def print
   @service = Service.find(params[:id])
   @date = params[:post]

   html=render_to_string("services/pdf.html.erb",:post=>@date,:layout=>false)
   kit = PDFKit.new(html, :page_size => 'Letter')
   kit.stylesheets << "#{Rails.root.to_s}/app/assets/stylesheets/pdf.css"
   send_data(kit.to_pdf, :type => :pdf,:disposition  => "inline") 
  end
end
