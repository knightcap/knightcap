#   Helper methods to help generate reports
require 'set'

module ReportsHelper
   # Count total number of responses
   #
   # * *Arguments*    :
   #   - +startDate+ -> Start date to count from
   #   - +endDate+ -> End date to count from
   # * *Returns* :
   #   - Integer of number of responses
   #
  def count_responses(startDate, endDate)
    count = 0
    @service.surveys.each do |survey|
      survey.results.each do |res|
        if res.done == false || res.updated_at < startDate || res.updated_at > endDate
          next
        end
        count += 1
      end
    end
    return count
  end
  
   # Get number of number of promoters,neutrals, and detractors, and the maximum number of any
   #
   # * *Arguments*    :
   #   - +startDate+ -> Start date to count from
   #   - +endDate+ -> End date to count from
   # * *Returns* :
   #   - Hash as {promoters=>number of promoters, neutrals=>number of neutrals, detractors=>number of detractors, count=>max of any}
   #
  def get_pdn_values(startDate, endDate)
     h = Hash.new
     h["pdn"] = Array.new
     h["count"] = 0
     promoters = 0
     detractors = 0
     neutrals = 0
    @service.surveys.each do |survey|
      survey.results.each do |res|
        if res.done == false || res.updated_at <= startDate || res.updated_at >= endDate
          next
        end
        #more than 8 == promoters
        if res.score >8
         promoters+=1
        #7, 8 == neutrals
        elsif res.score > 6
          neutrals+=1
        #else detractors
        else
          detractors +=1
        end
      end
    end
    
    #add all to array
    h["pdn"] << promoters << neutrals << detractors
   
    
    #determine max axis length
    h["count"] = h["pdn"].max
    return h
  end
  
  
   # Get all the words in comments, strip it from CommonWords::WORDS and their number of occurences
   #
   # * *Arguments*    :
   #   - +startDate+ -> Start date to count from
   #   - +endDate+ -> End date to count from
   # * *Returns* :
   #   - Hash as {(unique words) => (occurences of the word)}
   #
  def get_words_used(startDate, endDate)
    words = Array.new
    
    @service.surveys.each do |survey|
      survey.results.each do |res|
        if res.done == false || res.updated_at <= startDate || res.updated_at >= endDate
          next
        end
        #push every single word into word array
        words.concat(res.comments.upcase.split(/[^a-zA-Z]/))
      end
    end
    
    #count each word, word=> key count=>value
    count = Hash.new(0)
    words.each do |add| 
      if (!CommonWords::WORDS.include? add.downcase)
        count[add] +=1
      end
    end
    #return hashtable of (word, count)
    
    return count
  end
  
   # Get NPS Score and its PDNs by step
   #
   # * *Arguments*    :
   #   - +startDate+ -> Start date to count from
   #   - +endDate+ -> End date to count from
   # * *Returns* :
   #   -  Hash of hash with date as a key and its value is another hashtable of "average", "promoters", "neutrals", and "detractors" as keys and its values as value
   #
 def get_nps_response(startDate, endDate, step)
    npsResponse = Hash.new
    
    #create a hash for each date according to step
    dateIterator = startDate
    while (dateIterator <= endDate)
      dateKey = dateConverterByStep(dateIterator, step)

      npsResponse[dateKey] = Hash.new(0)
      npsResponse[dateKey]["promoters"]=0
      npsResponse[dateKey]["neutrals"]=0
      npsResponse[dateKey]["detractors"]=0
      
      dateIterator = dateIteratorByStep(dateIterator,step)
    end
    
    #catch any lost dates
    if (dateComparisonByStep(dateIterator, endDate, step))
      dateKey = dateConverterByStep(dateIterator, step)

      npsResponse[dateKey] = Hash.new(0)
      npsResponse[dateKey]["promoters"]=0
      npsResponse[dateKey]["neutrals"]=0
      npsResponse[dateKey]["detractors"]=0
    end
    
    @service.surveys.each do |survey|
      survey.results.reorder('updated_at').each do |res|
        date = dateConverterByStep(res.updated_at, step)
        
        if res.done == false || res.updated_at < startDate  || !npsResponse.has_key?(date)

          next
        end
        
        #Count number of p/d/n per date
          #9,10 promoters
          if res.score >8
           npsResponse[date]["promoters"]+=1
          #7, 8 == neutrals
          elsif res.score > 6
            npsResponse[date]["neutrals"]+=1
          #else detractors
          else
            npsResponse[date]["detractors"] +=1
          end
      end
    end
    
    # get average
    npsResponse.keys.each do |date|
      total = npsResponse[date]["promoters"] +  npsResponse[date]["neutrals"] +  npsResponse[date]["detractors"]
      npsResponse[date]["average"] = ((npsResponse[date]["promoters"] - npsResponse[date]["detractors"]).to_f/total) * 100
            if npsResponse[date]["average"].nan? 
        npsResponse[date] ["average"]= 0
      end

    end
    
    npsResponse
  end
  
  private
   # Get the next date by step
   #
   # * *Arguments*    :
   #   - +date+ -> Start date to count from
   #   - +step+ -> "Days", "Weeks", "Months", or "Years"
   # * *Returns* :
   #   - DateTime instance of the next date
   #
  def dateIteratorByStep(date,step)
   
    case step
    when "Days"
      date = date + 1.days
    when "Weeks"
      date = date + 1.weeks
    when "Months"
      date = date + 1.months
    when "Years"
      date = date + 1.years
    else
      date = date + 10.years #break all possible infinite loops
    end
    date
  end
  
   # Convert date format according to step 
   #
   # * *Arguments*    :
   #   - +date+ -> Start date to count from
   #   - +step+ -> "Days", "Weeks", "Months", or "Years"
   # * *Returns* :
   #   - String of format of date
   #
  def dateConverterByStep(date, step)
    case step
    when "Days"
      dateKey = date.strftime("%e/%m")
    when "Weeks"
      dayOfWeek = date.strftime("%u").to_i
      startOfWeek = date - dayOfWeek.days + 1.days
      dateKey = startOfWeek.strftime("%e/%m")
    when "Months"
      dateKey = date.strftime("%b %y")
    when "Years"
      dateKey = date.strftime("%Y")
    end
    dateKey
  end
  
   # Check if next date is within endDate
   #
   # * *Arguments*    :
   #   - +date+ -> Start date to count from
   #   - +endDate+ -> End dae to compare with
   #   - +step+ -> "Days", "Weeks", "Months", or "Years"
   # * *Returns* :
   #   - Boolean, true if next date within endDate
   #
  def dateComparisonByStep(date, endDate, step)
    case step
    when "Days"
      condition = (date.day <= endDate.day)
    when "Weeks"
      condition = (date.day + 7.days <= endDate.day)
    when "Months"
      condition = (date.month <= endDate.month)
    when "Years"
      condition = (date.year <= endDate.year)
    end
    condition
  end
end
