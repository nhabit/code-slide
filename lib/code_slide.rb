require 'rubygems'
require 'git'
require 'runner_constants'

class CodeSlide
  # call_hash defined in the constants.
  include CodeSlide::RunnerConstants
  
  attr_accessor :git, :current_step
     
  def initialize(args)
    
    @repository = args[:repository]
    raise MissingRepositoryError if !@repository    
    
    @git = Git.open( @repository )

  end

  def steps                                
    @git.branches.map{| brnch | brnch.name }
  end
  
  def start
    @current_step = 0
    checkout_current_step
  end
  
  def current_branch                 
    @git.current_branch
  end
  
  def previous_branch                 
    current = current_branch
    branches = sorted_branch_list
    wanted = nil
    branches.each_with_index do | step, ind |
      if step == current_branch
        wanted = ind-1
        break
      end
    end
    branches[wanted]
  end
  
  def sorted_branch_list
 
    steps.delete('master') 
    sorted_steps = steps.collect{| brn | 
      [ brn, (brn.match(/^(\d+)_/) ? $1.to_i : 0) , (brn.match(/^\d+_(\d+)_/) ? $1.to_i : 0)] 
    }.sort_by{|a| a[1] }.sort_by{|b| b[1]}.collect{|stp| stp[0]}
    sorted_steps.delete('master')
    sorted_steps
  end                
  
  def checkout(branch)
    @git.checkout(branch)
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
  
  def step(step_number)
    @current_step = step_number.to_i
    return checkout_current_step
  end
    
  def last           
    @current_step = -1
    checkout_current_step      
  end 
  
  def first        
    @current_step = 0
    checkout_current_step      
  end   
    
  def set_current_step
    @current_step = sorted_branch_list.index(@git.current_branch)
  end
  
  def checkout_current_step
    branch = sorted_branch_list[@current_step] 
    return checkout(branch)
  end
     
  def list_steps
    list_string = ""
    current = current_branch
    sorted_branch_list.each_with_index do | step, ind |
      if step == current_branch
        step << " [Current Step]"
      end
      step.gsub!(/_/," ")  
			step.sub!(/^\d+ /,"")
      
      list_string << "#{ind}) #{step}\n"
    end                        
    # puts list_string
    list_string
  end
                           
  def changed_files
    set_current_step
    return false if @current_step == 0
    previous_step = previous_branch
    this_step = current_branch
    new_files = []
    deleted_files = []
    modified_files = []
    git_diff = @git.diff(previous_step, this_step)
    git_diff.each do |file|
      if file.type == "new"
        new_files << [file.path ]
      elsif file.type == "modified"
        modified_files << [ file.path, "\t\t" + file.patch ]
      elsif file.type == "deleted"
        deleted_files << [ file.path ]
      end
    end
    {:new => new_files, :deleted => deleted_files, :modified => modified_files}
  end

  def changes
    changes_string = ""
    change_list = changed_files
    return "no changes" if change_list == false
    [:new,:deleted,:modified].each do | type |
      changes_string << "\n" + type.to_s.capitalize + " files\n"
      changes_string << "-------\n"
      if change_list[type].size == 0 
        changes_string << "None\n"
      else
        change_list[type].each{ |file| changes_string << file[0] + "\n" }
      end
    end
    # puts changes_string
    changes_string
  end          

  def file_mods
    changes_string = ""
    change_list = changed_files
    return "no mods" if change_list[:modified].size == 0
    change_list[:modified].each{ |file| changes_string << file[0] + "\n" + file[1] }
    changes_string 
  end

  def help_text
      puts "Code Slide Help"
      puts "------------------"
      puts "Run with the following commands:\n"
      CALL_HASH.keys.each do | com |
        hsh = CALL_HASH[com]
        puts "%-20s %s" % [ com.to_s + " :", hsh[:help] ]
      end
      puts "------------------"
      puts "Providing just a number will change to that particular step\n\n"
  end
  
  def client_run(command)
    
    case command 
      
    when /^(help|h)$/
      help_text
    when /\d+/ 
      response = send(:step, command)
      puts response if !response.nil?
    else 
      if respond_hash = CALL_HASH[command.to_sym]
        response = send(command.to_sym)
        if response_string = respond_hash[:respond_with]
          puts response_string
        else
          puts response if !response.nil?
        end
      else
        puts "sorry I do not understand '#{command}'"
      end
    end  
    
  end
  
end

class MissingRepositoryError < ArgumentError
end

  

              
