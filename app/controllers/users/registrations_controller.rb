class Users::RegistrationsController < Devise::RegistrationsController


  def new
    @teams = Team.all
    super
  end
 
 
  # Overwritten method of create user to give it a default role of TeamMember 
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
 def create
    build_resource

    if resource.save
        ug = Usergroup.find_or_create_by_name(:name => "TeamMember")
        ug.users << resource
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
    else
      flash[:alert] = resource.errors.full_messages.join("<br>").html_safe
      clean_up_passwords resource    
      respond_with({}, :location => "/")
    end
  end
  
 
  # Overwritten method of update user to give notification and error messages
  #
  # * *Arguments*    :
  #   - nil
  # * *Returns* :
  #   - nil
  #
 def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    if resource.update_with_password(params[:user])
      flash[:notice] = "Profile successfully updated."
      sign_in resource_name, resource, :bypass => true
      respond_with({}, :location => "/profile")
    else
      flash[:alert] = resource.errors.full_messages.join("<br>").html_safe
      clean_up_passwords resource    
      respond_with({}, :location => "/profile")
    end
  end
end