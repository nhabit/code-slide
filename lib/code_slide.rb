require 'rubygems'
require 'git'
require 'code_slide/runner_constants'

# CodeSlide is a class used to run and interface with git
# It's primary use is to facilitate relatively seamless presentations
# of code to training courses or talks
#                                     
require 'code_slide/scm'
require 'code_slide/ui_api'

module CodeSlide
  # call_hash defined in the constants.
  class WorkSpace

    include CodeSlide::RunnerConstants
    include CodeSlide::UIAPI

    attr_accessor :git, :current_step, :scm, :slide_runner
       
    def initialize(args)
      
      @repository = args[ :repository ]
      raise MissingRepositoryError if !@repository    
      @scm = args[ :scm ] || 'git'
      # for now:
      get_runner
    end

    def get_runner   
      @slide_runner = SCM_HASH[@scm.to_sym].call(@repository)
    end
    
    def previous_branch                 
      current = current_branch
      branches = sorted_branch_list
      branches.each_with_index do | step, ind |
        if step == current
          return branches[ind-1]
        end
      end                       
    end
  
  # is this too obfuscated? am I showing my perl-love?
  # the fact that i've always admired the grace of the schwartzian transform  
  # But, having said that, this does what i want, but i'm not sure why.
  # We sort on element 1 of our collected array, and then do the sort again on the same elemt.
  # This makes the following sort correctly 1_ddd, 1_1_sss, 1_2_dssa, 2_sss, 2_1_sss         
  # when i did it using two elements: 
  # [ branch, (branch.match(/^(\d+)_(\d*)_*/) ? $1.to_i : 0), $2.to_i ]
  # it just wouldn't work. Odd! and yet this still needs some explanation.
   
    def sorted_branch_list
      sorted_steps = steps.collect{| branch | 
        [ branch, (branch.match(/^(\d+)_/) ? $1.to_i : 0) ] 
      }.sort_by{| branch_array | branch_array[1] }.sort_by{|branch_array_again| branch_array_again[1]}.collect{|step| step[0]}
      sorted_steps.delete('master')
      sorted_steps
    end                
        
    def checkout(branch)
      stash if branch_changes?
      @slide_runner.checkout(branch)
    end 
    
    def step(step_number)
      @current_step = step_number.to_i
      return checkout_current_step
    end
      
    def set_current_step
      @current_step = sorted_branch_list.index(@slide_runner.current_branch)
    end
    
    def checkout_current_step
      branch = sorted_branch_list[@current_step] 
      return checkout(branch)
    end
  
    def step_string(step)
      step << " [Current Step]" if step == current_branch
      step.gsub!(/_/," ")  
      step.sub!(/^\d+ /,"")    
    end                      
    
    def changed_files
      set_current_step
      return false if @current_step == 0
      build_changed_file_hash
      @change_file_hash
    end
  
    def build_changed_file_hash
      @change_file_hash = { :new => [ ], :deleted => [ ], :modified => [ ] }
      previous_step = previous_branch
      this_step = current_branch
      slide_runner.diff(previous_step, this_step).each do | file |
        add_changes_from_diff( file )
      end             
    end
  
    def branch_changes?
      return true if @slide_runner.diff(current_branch, '.').size > 0
      return false
    end
  
    def stash
      @slide_runner.stash
      puts "Stashing changes."
    end
    
    def add_changes_from_diff( file )
      path = file.path
      case file.type
      when /new/
        @change_file_hash[ :new ]  << [ path ]
      when /modified/
        @change_file_hash[ :modified ] << [ path, "\t\t" + file.patch ]
      when /deleted/
        @change_file_hash[ :deleted ] << [ path ]
      end                          
    end           
    
    def process_change_type( type )
      type_array = @change_file_hash[type]
      @changes_string << "\n" + type.to_s.capitalize + " files\n"
      @changes_string << "-------\n"                             
      return  @changes_string << "None\n" if type_array.size == 0
      type_array.each{ |file| @changes_string << file[0] + "\n" } 
    end    
   

    def modifications?
      return false if @changed_file_hash[:modified].nil?
      true
    end
                    
  end
  #just a missing repository error - nothing to see here - move on
  class MissingRepositoryError < ArgumentError
  end
                 
end
  

              
