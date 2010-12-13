require File.dirname( __FILE__ ) + '/../lib/code_slide'
module CRHelper
  
  def get_runner_for( path )                                      
     @course_runner = CodeSlide.new( { :repository => path } )                                    
  end
  
  def create_repositories
    make_missing_directories
    make_missing_repositories
  end

  def make_path( dirname )
    File.join( File.dirname( __FILE__ ), 'fixtures', dirname )   
  end   
  
  def make_missing_directories
    [ 'no_repository', 'repository_1', 'repository_2', 'repository_3' ].each do | rep |
      repo_path = make_path( rep )
      if !File.exists?( repo_path )
        Dir.mkdir( repo_path )
      end
    end  
  end
  
  def add_file_commit_branch( git, file, branch=nil )
    File.open( file, 'w' ) { | f | f.write( "blah\n" ) }
    git.add( file ) 
    if !branch.nil? 
      git.commit( branch )
      git.branch( branch ).checkout   
    else
      git.commit("dummy")
    end
  end
  
  def make_missing_repositories
    [ 'repository_1', 'repository_2', 'repository_3', 'repository_4' ].each do | rep | 
      repo_path = make_path(rep)
      if !File.exists?( repo_path + "/.git" )
        git = Git.init( repo_path )
        case rep  
        when /repository_1/
            add_file_commit_branch(git, repo_path + "/file1" )
        when /repository_2/
          [ [ 'file1','first_branch' ], [ 'file2', 'second_branch' ],
            [ 'file3', 'third_branch' ] ].each do | file_branch |
            add_file_commit_branch(git, repo_path + "/#{file_branch[0]}", file_branch[1] )
          end
        when /repository_3/
          [ [ 'file1','1_first_branch' ], [ 'file2', '2_second_branch' ],
            [ 'file3', '3_third_branch' ] ].each do | file_branch |
            add_file_commit_branch(git, repo_path + "/#{file_branch[0]}", file_branch[1] )
          end
          git.checkout('2_second_branch')
          File.open( repo_path + '/file2', 'w+' ) { | f | f.write( "adding a line to file2\n" ) }
          git.add( repo_path + '/file2')
          git.commit("adding a dummy line")
        when /repository_4/  
          [ [ 'file1','1_1_branch' ], [ 'file2', '1_2_second_branch' ],
            [ 'file3', '2_third_branch' ], [ 'file4', '2_1_branch' ],
            [ 'file5', '3_fifth_branch' ] ].each do | file_branch |
            add_file_commit_branch(git, repo_path + "/#{file_branch[0]}", file_branch[1] )
          end
        end
      end
    end
  end
       
end

RSpec.configure do |config|
  config.include(CRHelper)
end     