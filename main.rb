require 'rest-client'
require 'csv'

class UMan
    
    def initialize
       
       @api_endpoint = 'https://syrup.keboola.com/gooddata-writer'
       @writer_id = 'jt_user_management_'
       @kbc_api_token = ''
       @users = 'data/users.csv'
       
       #testovaci pid -> budeme muset ziskat z Writeru
       @pid = 'x8rtiybsfuyxsrjqgw3quh4lrhco853a'
    
    end

    # get users from input CSV stored in KBC SAPI
    def get_user_config
        
        csv = CSV.read(@users, :headers => true)
        users = csv['project_id']

        return users
        
    end


    # get users from GoodData Project
    def get_users
    
        headers  = {:x_storageapi_token => @kbc_api_token, :accept => :json, :content_type => :json}
    
        response = RestClient.get "#{@api_endpoint}/users?writerId=#{@writer_id}", headers
    
        return response
  
    end

    # get role IDs for specific project
    def get_project_roles(pid)
  
        headers  = {:x_storageapi_token => @kbc_api_token, :accept => :json, :content_type => :json}
  
        query = "/gdc/projects/#{pid}/roles"
        
        response = RestClient.get "#{@api_endpoint}/proxy?writerId=#{@writer_id}&query=#{query}", headers
 
        # parse key values for specific project roles
 
        return response
    
    end
    
    #create new user in Keboola Organization
    def create_user(user,pass,firstname,lastname)
    
    #   test_user = 'jiri.tobolka+kbc@bizztreat.com'
    #   pass = 'akbvgdrz77'
    #   firstname = 'J'
    #   lastname = 'T'
    
        values   = "{ \"writerId\": \"#{@writer_id}\", \"email\": \"#{test_user}\", \"password\": \"#{pass}\", \"firstName\": \"#{firstname}\", \"lastName\": \"#{lastname}\"}"
        
        headers  = {:x_storageapi_token => @kbc_api_token, :accept => :json, :content_type => :json}
        
        response = RestClient.post "#{@api_endpoint}/users", values, headers
    
        return response
    
    end
    
    # does the post on projects/pid/users resource if not available sends invitation
    def add_to_project(user, role, pid)
        
        headers  = {:x_storageapi_token => @kbc_api_token, :accept => :json, :content_type => :json}
        
        values   = "{ \"writerId\": \"#{@writer_id}\", \"pid\": \"#{pid}\", \"email\": \"#{user}\", \"role\": \"#{role}\" }"
        
        response = RestClient.post "#{@api_endpoint}/project-users", values, headers
        
        return response
        
    end
    
    # deactivate user in GoodData project
    def deactivate_user(uid, pid)
    
        #user_id = "f6059d2cd367193ac21f1af2b639a78f"
        
        headers  = {:x_storageapi_token => @kbc_api_token, :accept => :json, :content_type => :json}
        
        query =     "/gdc/projects/#{pid}/users"
        
        payload = "{\"user\": { \"content\": { \"status\": \"DISABLED\", \"userRoles\": [ \"/gdc/projects/#{pid}/roles/2\" ]}, \"links\": {\"self\": \"/gdc/account/profile/#{uid}\"}}}"
        
        values = "{\n \"writerId\": \"#{@writer_id}\",\n \"query\": \"#{query}\",\n \"payload\": #{payload}\n}"

        response = RestClient.post "#{@api_endpoint}/proxy", values, headers
        
        return response
    
    end
    
    # activate existing user in GoodData project (only for users within your domain)
    def activate_user
        
        #user_id = "f6059d2cd367193ac21f1af2b639a78f"
        
        headers  = {:x_storageapi_token => @kbc_api_token, :accept => :json, :content_type => :json}
        
        query = "/gdc/projects/#{pid}/users"
        
        payload = "{\"user\": { \"content\": { \"status\": \"ENABLED\", \"userRoles\": [ \"/gdc/projects/#{pid}/roles/2\" ]}, \"links\": {\"self\": \"/gdc/account/profile/#{uid}\"}}}"
        
        values = "{\n \"writerId\": \"#{@writer_id}\",\n \"query\": \"#{query}\",\n \"payload\": #{payload}\n}"
        
        response = RestClient.post "#{@api_endpoint}/proxy", values, headers
        
        return response
    
    end
    
    # apply changes for users
    def set_users
        
    end
    
    # method for saving result in SAPI (log eventu)
    def save_output
    
    end

end


# test use case
manager = UMan.new

CSV.foreach('data/users.csv', :headers => true) do |csv|
    
    case csv['action']
        when "DISABLE"
            puts "#{csv['user']} - do nothing..."
        when "ENABLE"
            manager.add_to_project(csv['user'],'admin',csv['project'])
        else puts 'neco je spatne'
    end
    
end
