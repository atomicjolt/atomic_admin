module AtomicAdmin::Filtering
  extend ActiveSupport::Concern

  included do
    class_variable_set(:@@allowed_sort_columns, [])
    class_variable_set(:@@allowed_search_columns, [])
  end

  class_methods do
    def allowed_sort_columns(names)
      class_variable_set(:@@allowed_sort_columns, names)
    end

    def allowed_search_columns(names)
      class_variable_set(:@@allowed_search_columns, names)
    end
  end

  def query_params
    params.
      permit(:search, :sort_on, :sort_direction, :page, :per_page, :search_on).
      with_defaults(sort_direction: "asc", page: 1, per_page: 30)
  end

  def filter(relation)
    params = query_params
    allowed_search_columns = self.class.class_variable_get(:@@allowed_search_columns)

    if params[:search].present? && params[:search_on].present? && allowed_search_columns.include?(params[:search_on])
      relation = relation.where("lower(#{params[:search_on]}) LIKE ?", "%#{params[:search].downcase}%")
    end

    allowed_sort_columns = self.class.class_variable_get(:@@allowed_sort_columns)
    if params[:sort_on].present? && allowed_sort_columns.include?(params[:sort_on])
      sort_col = params[:sort_on]
      sort_dir = params[:sort_direction]
      sort_dir = "asc" if sort_dir == "ascending"
      sort_dir = "desc" if sort_dir == "descending"
      relation = relation.order({sort_col => sort_dir})
    end

    relation = relation.paginate(page: params[:page], per_page: params[:per_page])

    meta = {
      current_page: relation.current_page,
      next_page: relation.next_page,
      prev_page: relation.previous_page,
      total_pages: relation.total_pages,
      total_items: relation.total_entries,
    }

    [relation, meta]
  end
end
