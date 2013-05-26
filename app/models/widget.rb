class Widget
  attr_accessor :name, :description, :step, :scope
  
   # Constructor for widgets with default step "Monthly"
   #
   # * *Arguments*    :
   #   - +name+ -> Name of widget
   #   - +desc+ -> Description of widget
   # * *Returns* :
   #   - nil
   #
  def initialize(name, desc)
      @name = name
      @description = desc
      @scope = "global"
      @step = "Monthly"
   end
   
   # Creates a response widget
   #
   # * *Arguments*    :
   #   - nil
   # * *Returns* :
   #   - A Responses Widget
   #
   def self.responses
     Widget.new("Responses", "Shows surveys sent VS surveys completed")
   end
   
   # Create a promoters widget
   #
   # * *Arguments*    :
   #   - nil
   # * *Returns* :
   #   - A Promoters Widget
   #
   def self.promoters
     Widget.new("Promoters", "Shows number of promoters")
   end
   
   # Creates a neutrals widget
   #
   # * *Arguments*    :
   #   - nil
   # * *Returns* :
   #   - A Neutrals Widget
   #
   def self.neutrals
     Widget.new("Neutrals", "Shows number of neutrals")
   end

   # Creates a detractors widget
   #
   # * *Arguments*    :
   #   - nil
   # * *Returns* :
   #   - A Response Widget
   #   
   def self.detractors
     Widget.new("Detractors", "Shows number of detractors")
   end
   
   # Creates a list of all widgets
   #
   # * *Arguments*    :
   #   - nil
   # * *Returns* :
   #   - A Response Widget
   #
   def self.list
     ["Responses", "Promoters", "Neutrals", "Detractors"]
   end
   
   
   # Method to return a widget by giving the name
   #
   # * *Arguments*    :
   #   - +name+ -> Name of widget
   # * *Returns* :
   #   - A widget according to the name
   #
   def self.getWidgetByName(name)
     case name
     when "Responses"
       self.responses
     when "Detractors"
       self.detractors
     when "Promoters"
       self.promoters
     when "Neutrals"
       self.neutrals
     end
   end
end
