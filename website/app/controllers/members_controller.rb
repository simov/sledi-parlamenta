class MembersController < ApplicationController
  def index

    query = Member.all
    search_query = member_params[:q]
    query = query.search(search_query) unless search_query.blank?

    order = member_params[:order] || "first_name"
    constituency = member_params[:constituency]

    ids = member_params.slice(:party_id, :assembly_id).values.delete_if { |v| v.blank? }.map { |v| v.to_i }
    query = query.create_joins ids
    query = query.by_constituency(constituency) unless constituency.blank?
    query = query.order(order)

    @members = query.paginate(:page => member_params[:page])
  end

  def show
    @member = Member.find(params[:id])
  end

  private

  def member_params
    params.permit(:q, :order, :party_id, :assembly_id, :constituency, :page)
  end
end
