=begin
RailsCollab
-----------

=end

class AdministrationController < ApplicationController

  before_filter :login_required
  before_filter :process_session
  
  def index
  end
  
  def company
  	@company = Company.owner
  	render 'company/view_client'
  end
  
  def members
  	@company = Company.owner
  	@users = @company.users
  end
  
  def projects
  	@projects = @logged_user.projects
  end
  
  def clients
  	@clients = Company.owner.clients
  end
  
  def configuration
      flash[:flash_error] = "Edit config/config.yml for configuration options"
      redirect_back_or_default :controller => 'administration'
  end
  
  def tools
      flash[:flash_error] = "Unimplemented"
      redirect_back_or_default :controller => 'administration'
  end
  
  def upgrade
  	@versions = []
  end
  
  def authorize?(user)
  	return user.is_admin
  end
end