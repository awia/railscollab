=begin
RailsCollab
-----------

=end

class FileRepo < ActiveRecord::Base
	set_table_name 'file_repo'
	
	belongs_to :project_file_revision, :foreign_key => 'repository_id'
	
	# Helpers
	
	def self.handle_storage(value)
		case AppConfig.file_upload_storage
			when 'file_system'
				return nil
			when 'local_database'
			    file_repo = FileRepo.new(:content => value, :order => 0)
				file_repo.save!
				return file_repo.id
		end
		
		return nil
	end
	
	def self.handle_update(id, value)
		case AppConfig.file_upload_storage
			when 'file_system'
				return nil
			when 'local_database'
			    begin
			      file_repo = FileRepo.find(id)
			    rescue ActiveRecord::RecordNotFound
			      return nil
   				end
				file_repo.content = value
				file_repo.save!
				return file_repo.id
		end
		
		return nil
	end
	
	def self.handle_delete(id)
		case AppConfig.file_upload_storage
			when 'file_system'
				return true
			when 'local_database'
			    begin
			      file_repo = FileRepo.find(id)
			    rescue ActiveRecord::RecordNotFound
			      return false
   				end
				file_repo.destroy
				return true
		end
		
		return false
	end
	
	def self.get_data(id)
		case AppConfig.file_upload_storage
			when 'file_system'
				return nil
			when 'local_database'
			    begin
			      file_repo = FileRepo.find(id)
			    rescue ActiveRecord::RecordNotFound
			      return nil
   				end
				return file_repo.content
		end
		
		return nil
	end
end