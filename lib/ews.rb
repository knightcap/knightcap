require 'viewpoint'
include Viewpoint::EWS

# Module for accessing Exchange Web Services.
# Built on top of Viewpoint gem
module Ews

  # Method for obtaining unique email addresses from a predefined folder.
  #
  # * *Arguments*    :
  #   - +user+ -> The Exchange account username
  #   - +pass+ -> The Exchange account password
  #   - +folder_id+ -> The Exchange folder ID
  # * *Returns* :
  #   - Array of unique email addresses
  # * *Raises* :
  #   - +ArgumentError+ -> If username, password or foler_id is missing
  #
  def getEmailAddresses(user, pass, folder_id)
    raise ArgumentError, "Username and Password required" unless (user.present? && pass.present? && folder_id.present?)
    folder = _getSingleFolder(user, pass, folder_id)
    arr = Array.new
    folder.messages.each do |message|
      arr.push(message.sender.email) if !arr.include? message.sender.email
    end
    return arr
  end


  # Method for obtaining all folders of type 'IPF.Note'.
  #
  # These folders are able to store emails, and therefore are the ones
  # needed for the application. Also this speeds up the process as we don't
  # bother with uneccessary folders. 
  #
  # * *Arguments*    :
  #   - +user+ -> The Exchange account username
  #   - +pass+ -> The Exchange account password
  #   - +folder_id+ -> The Exchange folder ID
  # * *Returns* :
  #   - Hash as {folder_id => folder_name}
  # * *Raises* :
  #   - +ArgumentError+ -> If username or password is missing
  #
  def getFolders(user, pass)
    
    @cli = _getExchangeCredentials(user, pass)
    raise ArgumentError, "Username and Password required" unless (user.present? && pass.present?)
    @allFolders = @cli.folders :traversal => :deep, :folder_type => "IPF.Note"

    @result = Hash.new

    for child in @allFolders
      @result[child.id] = child.name
    end

    @result
  end


  private

  # Method for defining a Viewpoint EWS::Client instance.
  # Intended for internal use within the module only
  #
  # * *Arguments*    :
  #   - +user+ -> The Exchange account username
  #   - +pass+ -> The Exchange account password
  # * *Returns* :
  #   - Viewpoint::EWSClient instance
  # * *Raises* :
  #   - +ArgumentError+ -> If username or password is missing
  #
  def _getExchangeCredentials(user, pass)
    raise ArgumentError, "Username and Password required" unless (user.present? && pass.present?)
    # EVN is app environment, these params added via application.yml, loaded via application.rb
    endpoint = ENV["EWS_ENDPOINT"]
    # user = ""
    # pass = ""

    return Viewpoint::EWSClient.new endpoint, user, pass
  end


  # Method for retrieving a single folder from EWS by its ID
  # Intended for internal use within the module only
  #
 # * *Arguments*    :
  #   - +user+ -> The Exchange account username
  #   - +pass+ -> The Exchange account password
  #   - +folder_id+ -> The Exchange folder ID
  # * *Returns* :
  #   - Class: Viewpoint::EWS::Types::Folder
  # * *Raises* :
  #   - +ArgumentError+ -> If username, password or folder_id is missing
  #
  def _getSingleFolder(user, pass, folder_id)
    cli = _getExchangeCredentials(user, pass)
    return cli.get_folder folder_id
  end

end