class SearchesController < GroupDataController
  before_filter :check_max_search_notice, :only => [:new, :preview, :index]

  respond_to :html, :csv

  def new
    @search = Search.new do |s|
      s.creator = current_user
      s.group   = current_group
    end
    authorize! :search, @search
  end

  def preview
    @search = Search.new do |s|
      s.creator = current_user
      s.group   = current_group
      s.query   = params[:search]
    end

    #Rails.logger.debug "Step 1 => #{self.class}"
    authorize! :search, @search

    # @search.get_results!
  end

  def create
    @search = Search.new(params[:search]) do |s|
      s.creator = current_user
      s.group   = current_group
    end
    authorize! :create, @search

    if @search.save
      redirect_to [current_group, :searches]
    else
      render :preview
    end
  end

  def show
    @search = current_group.searches.find(params[:id])
    authorize! :search, @search

    respond_with(@search) do |format|
      format.html
      format.csv {
        send_data SearchCSV.new(@search).to_csv,
        :type => "text/csv; charset=utf-8; header=present",
        :filename => "terraling-#{@search.name}.csv" }
    end
  end

  def index
    @searches = current_user.present? ? current_group.searches.by(current_user) : [ Search.new ]
    collection_authorize! :update, @searches

    @search_comparison = SearchComparison.new do |sc|
      sc.creator  = current_user
      sc.group    = current_group
      sc.searches = @searches
    end
  end

  def destroy
    @search = current_group.searches.find(params[:id])
    authorize! :destroy, @search

    @search.destroy
    redirect_to [current_group, :searches], :notice => "You successfully deleted your search."
  end

protected

  def check_max_search_notice
    return unless user_signed_in? || flash[:notice]
    # TODO replace with class method
    if Search.where(:creator => current_user, :group => current_group).count >= Search::MAX_SEARCH_LIMIT
      flash.now[:notice] = "You have reached the system limit for saved searches (#{Search::MAX_SEARCH_LIMIT}). Please delete old searches before saving new ones."
    end
  end
end
