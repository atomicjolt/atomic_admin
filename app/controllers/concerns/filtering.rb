module Filtering
  extend ActiveSupport::Concern

  def query_params
    params.
      permit(:search, :sort_on, :sort_direction, :page, :per_page).
      with_defaults(sort_direction: "asc", page: 1, per_page: 30)
  end

  def filter(relation, search_col: nil)
    params = query_params
    if params[:search].present? && search_col.present?
      relation = relation.where("#{search_col} LIKE ?", "%#{params[:search]}%")
    end

    if params[:sort_on].present?
      sort_col = params[:sort_on]
      sort_dir = params[:sort_direction]
      sort_dir = "asc" if sort_dir == "ascending"
      sort_dir = "desc" if sort_dir == "descending"
      relation = relation.order(Arel.sql("#{sort_col} #{sort_dir}"))
    end

    relation = relation.paginate(page: params[:page], per_page: params[:per_page])

    relation
  end
end
