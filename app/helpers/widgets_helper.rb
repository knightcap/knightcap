module WidgetsHelper
  # Method to display widget according to widget object
  #
  # * *Arguments*    :
   #   - +widget+ -> widget to display 
   # * *Returns* :
   #   - String of widget to display
   #
  def displayWidget(widget) 
    case widget.name
    when "Responses"
      widgetGetResponses(:step => widget.step)
    when "Promoters"
      widgetGetPdn(:type => "promoters", :step => widget.step)
    when "Detractors"
      widgetGetPdn(:type => "detractors", :step => widget.step)
    when "Neutrals"
      widgetGetPdn(:type => "neutrals", :step => widget.step)
    end
  end
  
  private
  
  # Widget to get number of responses
   #
   # * *Arguments*    :
   #   - +options+ -> If team is provided, response will be for the team. Else if service is provided, response will only be for the service. 
   # * *Returns* :
   #   - String of "done/sent"
   #
  def widgetGetResponses(options = {})
    #get all services of current users
    allServices = Array.new
    
    if options[:service].nil?
      if options[:team].nil?
        current_user.teams.each do |team|
          team.services.each do |service|
            allServices << service
          end
        end
      else
        options[:team].services.each do |service|
          allServices << service
        end
      end
    else
      allServices << options[:service]
    end
      
    #get total results sent and total results done
    total = 0
    done = 0
    allServices.each do |service|
      service.surveys.each do |survey|
        survey.results.each do |result|
          if compareStep(options[:step],result)
            total +=1
            if result.done 
              done +=1
            end
          end
        end
      end
    end
  
    #return done/total
    comparison = done.to_s + "/" + total.to_s
  end
  
  # Widget to get number of promoters, neutrals, or detractors. Will read from options type and output accordingly.
   #
   # * *Arguments*    :
   #   - +options+ -> Options to select specific team or service. Type must be "promoters", "detractors", or "neutrals". 
   # * *Returns* :
   #   - Integer of number of "types"
   #
  def widgetGetPdn(options = {})
    type = options[:type]
    #get all services of current users
    allServices = Array.new
    
    if options[:service].nil? #if user didn't specify service
      if options[:team].nil? #if user didn't specify teams
        current_user.teams.each do |team|
          team.services.each do |service|
            allServices << service
          end
        end
      else
        options[:team].services.each do |service|
          allServices << service 
        end
      end
    else
      allServices << options[:service] #if user specify service, only one service in array
    end
      
    #results according to type
    count = 0
    allServices.each do |service|
      service.surveys.each do |survey|
        survey.results.each do |result|
          if compareStep(options[:step], result) && result.done
            case type
                when "promoters"
                  if result.score > 8 
                    count +=1
                  end
                when "neutrals"
                  if result.score > 6 && result.score < 8
                    count +=1
                  end
                when "detractors" 
                  if result.score <= 6
                    count +=1
                  end
                else
                  count +=1
              end
            end
          end
      end
    end
    count
  end
  
  # Private method to compare any date with step
   #
   # * *Arguments*    :
   #   - +step+ -> "Day", "Month", "Week"," Year" 
   #   - +result+ -> Result to compare with
   # * *Returns* :
   #   - Date
   #
   def compareStep(step, result)
     case step
      when "Monthly"
         return result.updated_at.month == DateTime.now.month && result.updated_at.year == DateTime.now.year
      when "Daily"
         return result.updated_at.day == DateTime.now.day && result.updated_at.month == DateTime.now.month && result.updated_at.year == DateTime.now.year
       when "Yearly"
         return result.updated_at.year == DateTime.now.year
       when "Weekly"
         return result.updated_at.to_date.cweek == DateTime.now.to_date.cweek
     end
      
   return false
   end
end