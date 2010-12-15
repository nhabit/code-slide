module CodeSlide
# UI API
# This module provides mix-in methods that are used as commands from the UI.
#
  module UIAPI

    def start
      @current_step = 0
      checkout_current_step
    end   
    
    def steps                                
      @slide_runner.step_names 
    end

    def current_branch                 
      @slide_runner.current_branch
    end
    
    def previous_branch                 
      current = current_branch
      branches = sorted_branch_list
      branches.each_with_index do | step, ind |
        if step == current
          return branches[ ind-1 ]
        end
      end                       
    end

    def next
      set_current_step                                              
      if @current_step < sorted_branch_list.size
        @current_step += 1 
        checkout_current_step      
      end
    end
    
    def prev
      set_current_step
      if @current_step > 0
        @current_step -= 1
        checkout_current_step      
      end
    end 

    def last           
      @current_step = -1
      checkout_current_step      
    end 
    
    def first        
      @current_step = 0
      checkout_current_step      
    end   
      
    def list_steps
      list_string = ""                                       
      sorted_branch_list.each_with_index do | step, ind |    
        list_string << "#{ind}) #{step_string(step)}\n"
      end                        
      list_string
    end

    def changes
      @changes_string = ""
      change_list = changed_files
      return "no changes" if change_list == false
      [ :new, :deleted, :modified ].each do | type |
        process_change_type( type )
      end
      @changes_string
    end          
   
    def file_mods                             
      return "no_mods" if !modifications?
      return_string = @changed_file_hash[ :modified ].inject(""){ | changes_string, modified_file |  changes_string << modified_file[ 0 ] + "\n" + modified_file[ 1 ] }
    end
  
    def help_text
      @help_string = <<e_string
Code Slide Help
------------------
Run with the following:
e_string
      RunnerConstants::CALL_HASH.keys.each do | com |
        hsh = RunnerConstants::CALL_HASH[ com ]
        @help_string << "%-20s %s" % [ com.to_s + " :", hsh[:help] ] + "\n"
      end
      @help_string << "Providing just a number will change to that particular step\n\n"
    end
    
    def client_run( command )
      
      case command           
      when /^(help|h)$/
        puts help_text
      when /\d+/ 
        response = send( :step, command )
        puts response if !response.nil?
      else
        command_sym = command.to_sym
        response_from_command( command_sym )
      end      
    end   

    def response_from_command( command )
      puts "sorry I do not understand #{command}" if !RunnerConstants::CALL_HASH.has_key?( command )
      respond_hash = RunnerConstants::CALL_HASH[ command ]
      response = send( command )
      if response_string = respond_hash[ :respond_with ]
        puts response_string
      else
        puts response if !response.nil?
      end
    end
    
  end

end    