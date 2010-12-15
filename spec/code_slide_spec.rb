#
#  code_slider_spec
#
#  Created by Andy Mendelsohn on 2010-11-28.
#  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
#

require File.dirname(__FILE__) + '/spec_helper'

describe CodeSlide do

  before(:all) do
    create_repositories
  end
  
  context "The initialization process" do

    it "should require arguments" do
      lambda{ @code_slider = CodeSlide.new()}.should raise_error
    end
  
    it "should require a repository key value pair and raise an error if there isn't one" do
      args_hash = {}
      lambda{ @code_slider = CodeSlide::WorkSpace.new(args_hash)}.should raise_error(CodeSlide::MissingRepositoryError)
    end
    
    it "should fail if the repository doesn't exist" do
      repo = File.dirname(__FILE__) + '/fixtures/no_repository'
      args_hash = {:repository => repo}           
      lambda  { @code_slider = CodeSlide::WorkSpace.new(args_hash)}.should raise_error
    end                                                             
    
    it "should create a new code_slider object, given a correct repository" do
      repo = File.dirname(__FILE__) + '/fixtures/repository_1'
      args_hash = {:repository => repo}
      lambda  { @code_slider = CodeSlide::WorkSpace.new(args_hash)}.should_not raise_error
    end

    it "should store the git instance in an instance variable" do
      repo = File.dirname(__FILE__) + '/fixtures/repository_1'
      args_hash = {:repository => repo}                                     
      @code_slider = CodeSlide::WorkSpace.new(args_hash)
      @code_slider.git.class.should == Git::Base
    end
  end

  describe "slide_runner" do
    
    before(:each) do 
      repo = File.dirname(__FILE__) + '/fixtures/repository_2'
      @code_slider = CodeSlide::WorkSpace.new({:repository => repo})
    end
    
    context "in default mode" do
      
      it "should return an instance of the git scm interface" do
        @code_slider.slide_runner.class.should == CodeSlide::CSGit
      end
    
    end
  end
  
      
  describe "steps" do                   
    before(:each) do 
      repo = File.dirname(__FILE__) + '/fixtures/repository_2'
      args_hash = {:repository => repo}                                     
      @code_slider = CodeSlide::WorkSpace.new(args_hash)
    end  
    
    it "should return a list of all the branches in the repository" do
      @code_slider.steps.should == [ 'second_branch','third_branch', 'master', 'first_branch']
    end                                                               
  end
  
  context "starting with a correctly named set of branches as per our naming standards for the code_slider" do 
    before(:each) do
      repo = File.dirname(__FILE__) + '/fixtures/repository_3'
      args_hash = {:repository => repo}                                     
      @code_slider = CodeSlide::WorkSpace.new(args_hash)
      @code_slider.start
    end
    
    describe "start" do                                                                                               
      it "should set the current_step to 0" do
        @code_slider.current_step.should == 0
      end
    end
    
    describe "help" do                                               
      it "should print a help description" do
         @code_slider.help_text().should =~ /Code Slide Help/
      end                                                            
    end   

    describe "sorted_branch_list" do                                 
      it "should return a numerically sorted list" do
        @code_slider.sorted_branch_list.should == ["1_first_branch", "2_second_branch", "3_third_branch"]
      end                                                                                                             
      
      it "should also be able to return a numerically sorted mixed list with point branches (1_1, 1_2, etc)" do
        repo = File.dirname(__FILE__) + '/fixtures/repository_4'
        args_hash = {:repository => repo}                                     
        @code_slider = CodeSlide::WorkSpace.new(args_hash)
        @code_slider.start
        @code_slider.sorted_branch_list.should == ["1_1_branch", "1_2_second_branch", "2_third_branch", "2_1_branch", "3_fifth_branch"]
      end                                                                                                             
      
      it "should not include 'master'" do
        @code_slider.sorted_branch_list.include?('master').should == false
      end                                                            
    end
    
    describe "current_branch" do
      it "should return the name of th current branch" do
        @code_slider.current_branch.should == "1_first_branch"
      end  
    end
    
    describe "step" do          
      it "should checkout a specific branch based on the step number" do
        @code_slider.step(2)  
        @code_slider.current_branch.should == "3_third_branch"
      end
    end
    
    describe "checkout" do      
      it "should checkout a specific branch" do
        @code_slider.checkout("3_third_branch")
        @code_slider.current_branch.should == "3_third_branch" 
      end
    end
    
    describe "checkout_current_step" do  
      it "should checkout a specific step based on current_step" do
         @code_slider.current_step = 1
         @code_slider.checkout_current_step
         @code_slider.current_branch.should == "2_second_branch"
      end  
    end
    
    describe "set_current_step" do       
      it "should set the current_step instance variable to the index of current branch in the sorted_branch_list" do
        @code_slider.git.checkout("1_first_branch")
        @code_slider.set_current_step
        @code_slider.current_step.should == 0
      end
    end
    
    describe "next" do                   
      it "should checkout the next branch" do
        @code_slider.next
        @code_slider.current_branch.should == "2_second_branch"
      end                                                         
      
      it "should silently remain on the last branch if we're already there" do
        @code_slider.checkout("3_third_branch")
        @code_slider.next
        @code_slider.current_branch.should == "3_third_branch"
      end  
    end
    
    describe "prev" do                   
      it "should checkout the previous branch" do
        @code_slider.checkout("3_third_branch")
        @code_slider.prev
        @code_slider.current_branch.should == "2_second_branch"
      end
      
      it "should silently remain on the first branch if we're already there" do
        @code_slider.checkout("1_first_branch") 
        @code_slider.prev
        @code_slider.current_branch.should == "1_first_branch"
      end  
    end
    
    describe "first" do                  
      it "should checkout the first branch" do
        @code_slider.first
        @code_slider.current_branch.should == "1_first_branch"
      end  
    end
    
    describe "last" do                   
      it "should checkout the last branch" do
        @code_slider.last
        @code_slider.current_branch.should == "3_third_branch"
      end                                
    end
    
    describe "list_steps" do             
      it "should display a list of the steps with underscores replaced by spaces" do
        @code_slider.list_steps.should match /2\) third branch/
      end  
    end

    describe "changed_files" do          
      it "should return false if we're on the first step" do
        @code_slider.checkout("1_first_branch") 
        @code_slider.changed_files.should == false
      end
      
      it "should list the files changed for the current_step" do
        @code_slider.checkout("3_third_branch") 
        @code_slider.changed_files.should == {
          :modified=>[ [ "file2", "\t\tdiff --git a/file2 b/file2\nindex 6fcde2e..907b308 100644\n--- a/file2\n+++ b/file2\n@@ -1 +1 @@\n-adding a line to file2\n+blah"] ],
          :deleted=>[],
          :new=>[]}
      end  
    end
    
    describe "branch_changes?" do
      
      before(:each) do
        repo = File.dirname(__FILE__) + '/fixtures/repository_3'
        args_hash = {:repository => repo}                                     
        @code_slider = CodeSlide::WorkSpace.new(args_hash)
        @code_slider.checkout('3_third_branch')
      end
    
      it "should return false if there have been any changes to this branch that differ from the repo copy" do
        @code_slider.branch_changes?.should == false
      end 
      
      it "should return true if there have been changes to this branch that differ from the repo copy" do
        repo_file = File.dirname(__FILE__) + '/fixtures/repository_3/file2'        
        fl = File.open( repo_file, 'a+' ) 
        fl.puts( "adding a new line to file2\n" )
        fl.close()
        @code_slider.branch_changes?.should == true
        fl = File.open( repo_file, 'w+' ) 
        fl.puts( "blah" )
        fl.close()
      end
    end

    describe "stash" do
      
      before(:each) do
        repo = File.dirname(__FILE__) + '/fixtures/repository_3'
        args_hash = {:repository => repo}                                     
        @code_slider = CodeSlide::WorkSpace.new(args_hash)
        @code_slider.checkout('3_third_branch')
      end
      
      it "should stash if there have been changes to this branch that differ from the repo copy, and return false to branch_changes" do
        repo_file = File.dirname(__FILE__) + '/fixtures/repository_3/file2'        
        fl = File.open( repo_file, 'a+' ) 
        fl.puts( "adding a new line to file2\n" )
        fl.close()
        @code_slider.branch_changes?.should == true
        @code_slider.stash
        @code_slider.branch_changes?.should == false
      end
    end
          
    describe "changes" do                
      it "should print \"no changes\" if we're on the first step" do
        @code_slider.checkout("1_first_branch")
        @code_slider.changes.should == "no changes"
      end
      
      it "should return a string if there are changes" do
        @code_slider.checkout("2_second_branch")
        @code_slider.changes.should == 
        "\nNew files\n-------\nfile3\n\nDeleted files\n-------\nNone\n\nModified files\n-------\nfile2\n"
      end  
    end
    
    describe "previous_branch" do        
      it "should return the name of the previous branch" do
        @code_slider.checkout("2_second_branch")
        @code_slider.previous_branch.should == "1_first_branch"
      end
    end
    
    describe "client_run" do             
      context "with 'start'" do          
        it "should set the current_step to 0" do
          @code_slider.client_run('start')
          @code_slider.current_step.should == 0
        end
      
        it "should call 'start'" do 
          @code_slider.should_receive(:response_from_command).with(:start)
          @code_slider.client_run('start')
        end
        
        context "calling response_from_command" do
          it "should print 'Course started'" do
            @code_slider.should_receive(:puts).with("Course started")
            @code_slider.response_from_command(:start)
          end
        end
      end
      
      context "with 'current_branch'" do 
        it "should call 'current_branch'" do 
          @code_slider.should_receive(:response_from_command).with(:current_branch)
          @code_slider.client_run('current_branch')
        end

        context "calling response_from_command" do
          it "should print '1_first_branch'" do
            @code_slider.should_receive(:puts).with("1_first_branch")
            @code_slider.response_from_command(:current_branch)
          end
        end
      end
      
      context "with 'last'" do           
        it "should call the 'last' method" do
          @code_slider.should_receive(:last)
          @code_slider.client_run('last')
        end

        it "should inform us we've switched to '2_second_branch'" do                                             
          @code_slider.should_receive(:puts).with("Switched to branch '3_third_branch'")
          @code_slider.response_from_command(:last)                                      
        end  
      end                                   
      
      context "with 'next'" do           
        it "should call the 'next' method" do
          @code_slider.should_receive(:next)
          @code_slider.client_run('next')
        end

        it "should inform us we've switched to '2_second_branch'" do                                           
          @code_slider.should_receive(:puts).with("Switched to branch '2_second_branch'")
          @code_slider.response_from_command(:next)
          @code_slider.current_branch.should == "2_second_branch"
        end                                 
      end                                         
      
      context "with 'prev'" do           
        it "should call the 'prev' method" do
          @code_slider.should_receive(:prev)
          @code_slider.client_run('prev')
        end

        it "should inform us we've switched to '2_second_branch'" do        
          @code_slider.last                  
          @code_slider.should_receive(:puts).with("Switched to branch '2_second_branch'")
          @code_slider.response_from_command(:prev)
          @code_slider.current_branch.should == "2_second_branch"
        end                                 
      end                                                     
      
      context "with 'first'" do          
        it "should call the 'first' method" do  
          @code_slider.last                  
          @code_slider.should_receive(:first) 
          @code_slider.client_run('first')
        end

        it "should inform us we've switched to '1_first_branch'" do
          @code_slider.last        
          @code_slider.should_receive(:puts).with("Switched to branch '1_first_branch'")
          @code_slider.response_from_command(:first)
          @code_slider.current_branch.should == "1_first_branch"
        end                                                   
      end
      
      context "with 'list_steps'" do     
        it "should call the 'list_steps' method" do  
          @code_slider.should_receive(:list_steps) 
          @code_slider.client_run('list_steps')
        end

        it "should provide a list of steps" do   
          @code_slider.response_from_command(:list_steps)
        end                                                   
      end

      context "with 'help'" do           
        it "should call the 'help_text' method" do  
          @code_slider.should_receive(:help_text) 
          @code_slider.should_receive(:puts)
          @code_slider.client_run('help')
        end
                                                               
      end 
      
      context "with a numeric value" do  
        it "should call step with the argument provided" do
          @code_slider.should_receive(:puts).with("Switched to branch '3_third_branch'")
          @code_slider.should_receive(:step).with('2').and_return("Switched to branch '3_third_branch'")
          @code_slider.client_run('2')
        end
        
      end                                                      
    end                                                        
  end                                   
end                                     
