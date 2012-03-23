class IdentitiesController < ApplicationController
layout "test"
  respond_to :json
  before_filter :login_required , :except => [:index,:new]
  
  def index
    @identities=Identity.all
    
     respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @identities }
     
    end
  end


  def new
    @identity = env['omniauth.identity']
     respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @identities }
     
    end
  end
  
  def getCategories
         render :template  => 'identities/getCategories'
  end

  def getRateMy
         render :template  => 'identities/getRateMy'
  end
  
  def edit
    @identity = Identity.find(params[:id])
    
    #respond_with @identity
  end
  
  def update
    @identity = Identity.find(params[:id])  
  	
  	respond_to do |format|
	      if @identity.update_attributes(params[:identity])
	        format.html { redirect_to(root_url) }
	        format.json { render json: @identity }
	      else
	        format.html { render :action => "edit" }
	        format.json { render :action => "edit" }
	      end
	    end    
  end
    
  def update_categories
    @identity = Identity.find(current_identity1.id)  
  	
  	respond_to do |format|
	    if @identity.update_attributes(:categories => params[:categories])
	       format.html { redirect_to(root_url) }
	       format.json { render json: @identity }
	    else
	        format.html { render :action => "edit" }
	        format.json { render :action => "edit" }
	    end
	 end    
  end
  
    def getNamesOnId
 
   @identities = Identity.find_all_by_id(params[:id])
    
    respond_to do |format|

      format.json { render json: @identities }
    end
  end
  
  def show
    @identity = Identity.find(params[:id])
    respond_to do |format|
      format.html 
      format.json { render json: @identity }
    end
  end  
end
