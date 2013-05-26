# Application wide helper methods
module ApplicationHelper
  
  # Determine if current user is a admin in the team. Add link to tables for sorting
  #
  def sortable(column, title = nil)
    # sort_column & sort_direction come from private methods in Service controller
    # private methods used to set defaults for params and prevent SQL injection
    #
    # two classes are set, 'current', and either 'asc' or 'desc', depending on sort direction
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
  
   # Determine if current user is a admin in the team
   #
   # * *Arguments*    :
   #   - +teamid+ -> Team ID
   # * *Returns* :
   #   - Boolean (true if current user is an admin)
   #
  def is_team_admin(teamid)
    # Logic for what team role current user has
    begin
      role = current_user.teamsusers.find_by_team_id(teamid).role
      return role == "admin" ? true : false
    rescue
      # role will not be present in cases where the user has had the service shared with them.
      # In these cases, treat these users as standard members of a service.
      return false
    end
  end
  
   # Encrypts a string using Zlib's Deflate (fastest option). Method converts binary to hexadecimal
   #
   # * *Arguments*    :
   #   - +string+ -> String to encrypt
   # * *Returns* :
   #   - String of encrypted text
   #
  def encrypt(string)
    z = Zlib::Deflate.new(Zlib::BEST_SPEED)
    dst = z.deflate(string, Zlib::FINISH)
    z.close
    return bin_to_hex(dst)
  end

   # Decrypts a string using Zlib's Inflate (fastest option). Method converts hexadecimal to binary
   #
   # * *Arguments*    :
   #   - +string+ -> Hexadecimal string to decrypt
   # * *Returns* :
   #   - String of decrypted text
   #
  def decrypt(string)
    begin
    zstream = Zlib::Inflate.new
    binary = hex_to_bin(string)
   
    buf = zstream.inflate(binary)
    zstream.finish
    zstream.close
    return buf
    rescue
      return -1
    end
  end
  
  private
   # Converts from binary text to hexadecimal
   #
   # * *Arguments*    :
   #   - +s+ -> text to convert
   # * *Returns* :
   #   - String of hexadecimal text
   #  
  def bin_to_hex(s)
    s.unpack('H*').first
  end

   # Converts from hexadecimal text to binary
   #
   # * *Arguments*    :
   #   - +s+ -> text to convert
   # * *Returns* :
   #   - String of binary text
   #  
  def hex_to_bin(s)
    s.scan(/../).map { |x| x.hex }.pack('c*')
  end
  
  def sort_column
    Service.column_names.include?(params[:sort])? params[:sort] : "name"
  end

  def sort_direction
   %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end
