
class SurveysController < ApplicationController

  before_filter :authenticate_user!, :except => [:survey, :submitSurvey ]
  before_filter :isadmin, :except => [:survey, :submitSurvey ]
  # this helper_method call is required in order to register the helper methods.
  include ApplicationHelper
  include ServicesHelper

  # Exchange Web Services Interface - lib/ews.rb
  require_dependency 'ews'
  include Ews
  
  # this stores all the entries currently added to the email list.
  @@emailList = Array.new
  
  # Index page for the survey index view.
  #
  # * *Returns* :
  #   - nil
  #
  def index
    @service = Service.find(params[:id])

    if !checkService(@service)
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      # wipe the email list and start from scratch if a refresh is required
      if params[:refresh]=="true"
        @@emailList = Array.new
        dlist = Dlist.where(:service_id => @service.id)
        for entry in dlist do
          validateAddEmail(entry.email, @service)
        end
      end
  
      # Sets a ews_folder_flag to true if there is a folder record in the database.
      # This is used in the view to determine how to display the EWS option 
      @ews_folder_flag = true if Servicesuser.where("service_id = ? AND user_id = ?" , params[:id], current_user.id).limit(1).first
  
      
      # If a user has attemnpted to login to change a exchange folder enter this branch
        if params[:user_name].present? || params[:password].present?
          begin
            ews_emails = getEmailsEWS(params[:user_name], params[:password])
            addEmailsEWS(ews_emails)
            flash.now[:notice] = "Your email addresses have been successfully loaded."
          rescue
            flash.now[:alert] = "The Exchange username/password entered is incorrect. Please try again."
          end
        end
      
      # Parse csv file if one is uploaded
      if params[:csv].present?
        if (params[:csvfile].nil?)
          flash.now[:alert] = "There was an error while trying to process your CSV file."
        else
          emails = parseCsv(params[:csvfile])
          for email in emails do
            validateAddEmail(email, @service)
          end
        end
      end
      
      @emails = @@emailList
    end
  end

  # Creates empty results entries of all e-mails in the database and send out the e-mails using DelayedJobs
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def sendEmail
    #create database entries
    @service = Service.find(params[:id])
    survey = @service.surveys.create()

    @@emailList.each do |email|
      survey.results.create(:done => false, :email => email, :score => nil, :comments => nil)
      url = "#{request.protocol}#{request.host_with_port}" + ENV["SUB_DIRECTORY"] + "/survey?a=" + encrypt(email) + "&b=" + encrypt(survey.id.to_s)
      Mailer.delay.invitation(email, @service, url)
      #Mailer.invitation(email, @service, url).deliver
    end
    
    respond_to do |format|
      format.html { redirect_to services_url, notice: 'Your survey has been sent.' }
      format.json { head :no_content }
    end
  end
  
  # Renders a survey according to encrypted "GET" parameters. 
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  # * *Raises* :
  #   - ActiveRecord::RecordNotFound if GET parameters are corrupted
  #
  def survey
    email = decrypt(params[:a])
    surveyId = decrypt(params[:b])
    if email == -1 || surveyId == -1
      raise ActiveRecord::RecordNotFound
    else
      #find or create survey
      
      survey= Survey.find(surveyId)
      @service = survey.service
      #find result with the email
      @result = Result.where(:survey_id => survey.id, :email => email)
     
     if @result.first.nil?
        raise ActiveRecord::RecordNotFound
     else
        respond_to do |format|
          format.html {render :layout=>false}
          format.json { render json: @service }
        end
      end
    end
  end

  # Saves the results of the submitted survey
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  # * *Raises* :
  #   - ActiveRecord::RecordNotFound if survey already done
  #    
  def submitSurvey
    email = decrypt(params[:a])
    surveyId = decrypt(params[:b])
    survey = Survey.find(surveyId)
    result = Result.where(:survey_id => survey.id, :email => email).first
    @service = survey.service
    
    if (!result.done?)
      result.done = true
      result.score = params[:score]
      result.comments = params[:comments][:box]
      result.save!
    else
      raise ActiveRecord::RecordNotFound
    end
    respond_to do |format|
      format.html { render :layout=>false }
      format.json { head :no_content }
    end
  end

  
  # Parse an uploaded csv file, and return a list of emails.
  #
  # * *Args*    :
  #   - params -> A StringIO or an instance of File backed by a temporary file
  # * *Returns* :
  #   - Array<string>
  #
  def parseCsv(csvfile)
    emailString = csvfile.read
    return emailString.split(',').map(&:strip)
    #parseCsv no longer adds emails, that is done in validateAddEmail
  end
  
  
  # Add an entry to the email list, if it is a valid email address.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def addEmail
    service = Service.find(params[:id])
    result = validateAddEmail(params[:email], service)
    @emails = @@emailList
    
    if result == "blacklisted" || result =="existing" || result == "globalblisted"
      render :text => result
    else 
      
      respond_to do |format|
        format.html { render :layout=>false }
        format.json { head :no_content }
      end
    end
    
    
  end


  # Method for obtaining emails to outgoing survey list via Exchange Web Services.
  #
  # 
  # Asks for credentials each request, and will scan a predefined
  # folder nominated by the user for email addresses.
  #
  # * *Args*    :
  #   - +user+ -> The Exchange account username
  #   - +pass+ -> The Exchange account password
  # * *Returns* :
  #   - nil
  # * *Raises* :
  #   - +ArgumentError+ -> If username or password is missing
  #
  def getEmailsEWS(user, pass)
    raise ArgumentError, "Username and Password required" unless (user.present? && pass.present?)
    folder_id = Servicesuser.where("service_id = ? AND user_id = ?" , params[:id], current_user.id).limit(1).first.ews_id
    @folder = getEmailAddresses(user, pass, folder_id)
  end


  # Method for adding emails to outgoing survey list
  #
  # Differs from above implementation, as the above implementation relies
  # on the :email symbol to be present.
  # 
  #
  # * *Arguments*    :
  #   - +emails+ -> The array of email addresses
  # * *Returns* :
  #   - nil
  # * *Raises* :
  #   - +ArgumentError+ -> If array of emails is missing
  #
  def addEmailsEWS(emails)
    raise ArgumentError, "Username and Password required" unless (emails.present?)
    
    service = Service.find(params[:id])
    emails.each do |email|
      validateAddEmail(email, service)
    end
    
    @emails = @@emailList
    
  end
  
  
  # Remove an entry from the email list
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def removeEmail
    email = (params[:email])
    
    if @@emailList.include?(email)
      @@emailList.delete(email)
    end
    
    @emails = @@emailList
    
    respond_to do |format|
      format.html { render :layout=>false }
      format.json { head :no_content }
    end
  end
  
  
  # Add an email to the blist table and remove it from the email list,
  # Then redirect view back to the emailListIndex view.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def blacklist
    service = Service.find(params[:id])
    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      email = params[:email]
      entry = service.blists.find_or_create_by_email(:email => email)
      @@emailList.delete(email)
      
      respond_to do |format|
        format.html { redirect_to :surveyindex }
        format.json { head :no_content }
      end
    end
  end
  
  
  # Index page for the emailListIndex view.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def emailListIndex
    @service = Service.find(params[:id])
    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      @dlist = Dlist.where(:service_id => params[:id])
      @blist = Blist.where(:service_id => params[:id])
  
      respond_to do |format|
        format.html
        format.json { head :no_content }
      end
    end
  end
  
  
  # Remove a single email from the dlist table, redirect view back to the emailListIndex view.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def dlistRemove
    service = Service.find(params[:id])
    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      email = (params[:email])
      entry = Dlist.find_by_email_and_service_id(email, service.id)
      if !entry.nil? 
        entry.destroy
      end
      
      respond_to do |format|
        format.html { redirect_to :emaillists }
        format.json { head :no_content }
      end
    end
  end
  
  # Add a single email to the dlist table, redirect view back to the emailListIndex view.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def dlistAdd
    service = Service.find(params[:id])
    email = params[:email]
    
    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      
      if emailRegex(email)
        entry = service.dlists.find_by_email(email)
        if !entry.nil?
          redirect_to :emaillists, alert: "The email address you are trying to add already exists in the distribution list."
        else
          service.dlists.create(:email => email)
	  redirect_to :emaillists
        end
      else
	redirect_to :emaillists, alert: "The email address you are trying to add is invalid"
      end
    end
  end
  
  # Adds CSV list into distribution list
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def dlistAddCsv
    service = Service.find(params[:id])
    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    elsif params[:d_csv].nil? 
      redirect_to :emaillists, :alert => "There was an error while trying to process your CSV file."
    else  
      emails = parseCsv(params[:d_csv])
      for email in emails do
        if emailRegex(email)
          service.dlists.find_or_create_by_email(email)
        end
      end

      respond_to do |format|
        format.html { redirect_to :emaillists }
        format.json { head :no_content }
      end
    end
  end
  
  # Add a single email to the blist table, redirect view back to the emailListIndex view.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def blistRemove
    service = Service.find(params[:id])
    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      email = (params[:email])
      entry = Blist.find_by_email_and_service_id(email, service.id)
      if !entry.nil?
        entry.destroy
      end
      
      respond_to do |format|
        format.html { redirect_to :emaillists }
        format.json { head :no_content }
      end
    end
  end
  
  
  
  # Add a single email to the blist table, redirect view back to the emailListIndex view.
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def blistAdd
    service = Service.find(params[:id])
    email = params[:email]

    if !@isadmin
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    else
      
      if emailRegex(email)
        entry = service.blists.find_by_email(email)
        if !entry.nil?
          redirect_to :emaillists, alert: "The email address you are trying to add already exists in the blacklist."
          return
        else
          service.blists.create(:email => email)
          respond_to do |format|
            format.html { redirect_to :emaillists }
            format.json { head :no_content }
          end
        end
      else
        redirect_to :emaillists, alert: "The email address you are trying to add is invalid"
      end
    end
  end
  
  # Add CSV list into blacklists
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
  def blistAddCsv
    service = Service.find(params[:id])
    
    if !checkServiceAdmin(service)
      redirect_to services_path, alert: "You do not have the privileges required to view this service."
    elsif params[:b_csv].nil?
      redirect_to :emaillists, :alert => "There was an error while trying to process your CSV file."
    else
      emails = parseCsv(params[:b_csv])
      for email in emails do
        if emailRegex(email)
          service.blists.find_or_create_by_email(email)
        end
      end

      respond_to do |format|
        format.html { redirect_to :emaillists }
        format.json { head :no_content }
      end
    end
  end
  
  
  # Validate if an email is correct.  If it is, add it to the email list.
  #
  # * *Arguments*    :
  #   - email -> An email address (string)
  #   - service -> Service to check blist and gblist from
  # * *Returns* :
  #   - status of validateAddEmail if any
  #
  def validateAddEmail(email, service)
    if emailRegex(email)
      if !@@emailList.include?(email)
        blistResult = Blist.where(:email => email, :service_id => service.id)
        gblistResult = Globalblist.where(:email => email)
        if (blistResult.empty? && gblistResult.empty?)
          @@emailList.push(email)
        else
          if !blistResult.empty?
              result = "blacklisted"
          elsif !gblistResult.empty?
            result = "globalblisted"
          end
        end
      else
        result = "existing"
      end
    end
  end
  
  
  # Checks that the email address is a valid email address
  #
  # * *Arguments*    :
  #   - email -> An email address (string)
  # * *Returns* :
  #   - index of the first match (int) or nil
  #
  def emailRegex(email) 
    email =~ /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
  end
  
  # Checks if user is an admin of the team the service belongs to
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - true if user is a admin of the team the service belongs to
  #
  def isadmin
    @isadmin = checkServiceAdmin(Service.find(params[:id]))
  end
end
