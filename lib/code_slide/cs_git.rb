module CodeSlide
# an interface class to handle SCM provided by git.
# This is essentially our slide_runner.
# If we should create interfaces to other compatible SCM systems,
# we can create an CodeSlide::CSclass for them :
# i.e CodeSlide::CSDarcs - CodeSlide::CSMercurial
# etc...
  class CSGit
    
    def initialize( args_hash )
      @repository = args_hash[ :repository ]
      @git = Git.open( @repository )
    end 

    def step_names
      @git.branches.map{ | branch | branch.name }
    end
    
    def current_branch
      @git.current_branch
    end 
    
    def checkout( branch )
      @git.checkout( branch )
    end
    
    def stash
      Git::Stash.new( @git,"WIP" ).save      
    end

    def diff( previous_step, this_step )
      @git.diff( previous_step, this_step )
    end
    
  end
end             