module ServicesHelper
  # sort_column & sort_direction are private helper methods for setting current sortable column, and sort directon
  # prevents SQL injection by checking user input and providing safe defaults.

  # Get score of a service
  #
  # Score is calculated by subtracting detractors from promoters and dividing by total responses
  # eg: total 100, P=70, N=10, D=20 -> Score = 50/100, which is 0.5 or 50%
  #
  # * *Arguments*    :
  #   - +service+ -> Service to get score
  # * *Returns* :
  #   - Integer of score
  #
  def get_score(service)
    promoters = 0
    detractors = 0
    count = 0
    service.surveys.each do |survey|
      survey.results.each do |res|
        if res.done == false
          next
        end
        tempScore = res.score
        # Adding to_integer method to try and weed out bad data.
        if tempScore.to_i >= 9 && tempScore.to_i <= 10
          promoters += 1
        elsif tempScore.to_i >= 0 && tempScore.to_i <= 6
          detractors += 1
        end
        count +=1
      end      
    end
    
    if count == 0
      return 0
    end
    return ((promoters - detractors).to_f/count * 100).round()
  end
  
  
  # Get trend of a service, comparing score of previous month and this month
  #
  # 0 for uptrend
  # 1 for no trend
  # 2 for downtrend
  #
  # * *Arguments*    :
  #   - +service+ -> Service to get trend
  # * *Returns* :
  #   - Integer of 0, 1, or 2
  #
  def get_trend(service)
    lastMonth = Hash.new
    thisMonth = Hash.new
    
    lastMonth["promoters"] =0
    lastMonth["neutrals"] =0
    lastMonth["detractors"] =0
    thisMonth["promoters"] =0
    thisMonth["neutrals"] =0
    thisMonth["detractors"] =0
    service.surveys.each do |survey|
      survey.results.reorder('updated_at').each do |res|
        
        if res.done == false || res.updated_at <= DateTime.now - 2.months
          next
        end

        if res.updated_at <= DateTime.now - 30.days
           if res.score >8
             lastMonth["promoters"]+=1
            #7, 8 == neutrals
            elsif res.score > 6
              lastMonth["neutrals"]+=1
            #else detractors
            else
              lastMonth["detractors"] +=1
            end
        else
          if res.score >8
             thisMonth["promoters"]+=1
            #7, 8 == neutrals
            elsif res.score > 6
              thisMonth["neutrals"]+=1
            #else detractors
            else
              thisMonth["detractors"] +=1
            end
        end
      end
    end
    
    lastAverage = (lastMonth["promoters"] - lastMonth["detractors"]).to_f / (lastMonth["promoters"] + lastMonth["detractors"] + lastMonth["neutrals"]) * 100
    thisAverage = (thisMonth["promoters"] - thisMonth["detractors"]).to_f / (thisMonth["promoters"] + thisMonth["detractors"] + thisMonth["neutrals"]) * 100
    
    if lastAverage.nan?
      lastAverage = 0
    end
    
    if thisAverage.nan?
      thisAverage = 0
    end
    
    if lastAverage > thisAverage
      return 2
    elsif lastAverage < thisAverage
      return 0
    else 
      return 1
    end
  end
  
  # Use get_trend function and style trend arrows
  #
  # * *Arguments*    :
  #   - +service+ -> Service to get trend
  # * *Returns* :
  #   - String of the style
  #
  def trend_style(service)
    trend = get_trend(service)
    
    return trend*57
 
  end
  
  # Used on the new service page to decide with team, if any to auto populate
  # myTeam is used directly after a team is created from the new service page
  #
  # * *Arguments*    :
  #   - +service+ -> Service to get trend
  #   - +myTeam+ -> Team to be populated, if any
  # * *Returns* :
  #   - Team instance
  #
  def myTeamSelect(service, myTeam)
    if !myTeam.nil?
      return myTeam
    else
     return (service.team.nil?)? "" : service.team.id
    end
  end
  
  # Checks if current user is an admin of the team owning a particular service
  #
  # * *Arguments*    :
  #   - +service+ -> Service to check if user is an admin of
  # * *Returns* :
  #   - Boolean, true if current user is an admin
  #
  def checkServiceAdmin(service) 
    return (current_user.teams.include?(service.team) && is_team_admin(service.team))
  end
  
  # Checks if current user is a member of the team owning a particular service
  #
  # * *Arguments*    :
  #   - +service+ -> Service to check if user is an admin of
  # * *Returns* :
  #   - Boolean, true if current user belongs to the team
  #
  def checkService(service)
    return (current_user.teams.include?(service.team)) 
  end
end
