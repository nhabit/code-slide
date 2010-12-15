# constants for use in codeslide - saves on the clutter and facilitates look up and dynamic despatch
module CodeSlide                                                                                     
  module RunnerConstants
    # this is a list of the callable method and their respective help messages. It's also a place to hold configuration 
    CALL_HASH = { 
      :start => { :respond_with => 'Course started', :help => "Start the course - sets the runner to 0 - probably not necessary" },
      :current_branch => {:help => "Prints the current branch name"},
      :last => {:help => "Checks out the last step"},
      :first => {:help => "Checks out the first step"},
      :prev => {:help => "Checks out the previous step"},
      :next => {:help => "Checks out the next step"},
      :changes => {:help => "Lists the files changed between this step and the previous one"},
      :list_steps => {:help => "Lists the possible steps and their order"},
      :file_mods => {:help => "Lists the files and their modifications between this step and the previous one"}
    }
    
    # this is how we create our SCM classes. sweet, sweet closures
    SCM_HASH = {
      :git => proc{ | arg_hash | CodeSlide::CSGit.new( arg_hash ) }
    }                          
    
  end                                                           
  
end
