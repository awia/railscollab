=begin
RailsCollab
-----------

=end

class ProjectMessage < ActiveRecord::Base
	include ActionController::UrlWriter
	
	belongs_to :project_milestone, :foreign_key => 'milestone_id'
	belongs_to :project
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
	
	has_many :comments, :as => 'rel_object', :dependent => :destroy
	has_many :tags, :as => 'rel_object', :dependent => :destroy
	has_many :attached_file, :as => 'rel_object', :dependent => :destroy
	
	has_many :project_file, :through => :attached_file
	
	has_and_belongs_to_many :subscribers, :class_name => 'User', :join_table => 'message_subscriptions', :foreign_key => 'message_id'

	before_create :process_params
	before_update :process_update_params
	before_destroy :process_destroy
	 
	def process_params
	  write_attribute("created_on", Time.now.utc)
	end
	
	def process_update_params
      write_attribute("updated_on", Time.now.utc)
	end
	
	def process_destroy
      AttachedFile.clear_attachments(self)
	end
	
	def tags
	 return Tag.list_by_object(self).join(',')
	end
	
	def tags=(val)
	 Tag.clear_by_object(self)
	 Tag.set_to_object(self, val.split(',')) unless val.nil?
	end
	
	def object_name
	  return self.title
	end
	
	def object_url
		url_for :only_path => true, :controller => 'message', :action => 'view', :id => self.id, :active_project => self.project_id
	end
	
	def attached_files(with_private)
		self.project_file
	end
		
    # Core permissions
    
	def self.can_be_created_by(user, project)
	  user.has_permission(project, :can_manage_messages)
	end
	
	def can_be_edited_by(user)
	 if (!self.project.has_member(user))
	   return false
	 end
	 
	 if user.has_permission(project, :can_manage_messages) 
	   return true
	 end
	 
	 if self.created_by == user
	   return true
	 end
	 
	 return false
    end

	def can_be_deleted_by(user)
	 if !self.project.has_member(user)
	   return false
	 end
	 
	 if user.has_permission(project, :can_manage_messages)
	   return true
	 end
	 
	 return false
    end
    
	def can_be_seen_by(user)
	 if !self.project.has_member(user)
	   return false
	 end
	 
	 if user.has_permission(project, :can_manage_messages)
	   return true
	 end
	 
	 if self.is_private and !user.member_of_owner?
	   return false
	 end
	 
	 return true
    end
    
    # Message permissions
    
    def can_be_managed_by(user)
      return user.has_permission(self.project, :can_manage_messages)
    end
    
    def file_can_be_added_by(user)
      return user.has_permission(self.project, :can_upload_files)
    end
    
    def options_can_be_changed_by(user)
      return (user.member_of_owner? and self.can_be_edited_by(user))
    end
    
    def comment_can_be_added_by(user)
      return (user.member_of(self.project) and self.comments_enabled)
    end

	def self.select_list(project)
	   ProjectMessage.find(:all, :conditions => "project_id = #{project.id}", :select => 'id, title').collect do |message|
	      [message.title, message.id]
	   end
	end
	
	# Accesibility
	
	attr_accessible :title, :text, :additional_text, :milestone_id
	
	# Validation
	
	validates_presence_of :title
	validates_presence_of :text
end