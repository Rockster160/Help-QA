module AuditHelper

  def set_audit_filters
    @audits = Sherlock.order(created_at: :desc).page(params[:page]).per(50)

    dicovery_type_filter = current_filter[:discovery_types].to_a.map(&:to_sym)
    @audits = @audits.by_type(*dicovery_type_filter) if dicovery_type_filter.any?
    dicovery_klass_filter = current_filter[:discovery_klasses].to_a.map(&:to_sym)
    @audits = @audits.by_klass(*dicovery_klass_filter) if dicovery_klass_filter.any?

    @audits = @audits.search_ip(current_filter[:ip].split(",")) if current_filter[:ip].present?
    @audits = @audits.where(acting_user_id: current_filter[:acting_uid].split(",")) if current_filter[:acting_uid].present?

    if current_filter[:meta_id].present?
      queries = []
      current_filter[:meta_id].split(",").each do |search_id|
        klass, meta_id = search_id.include?("-") ? search_id.split("-") : ["", search_id]
        klass_query = if klass.present? && Sherlock.discovery_klasses.include?(klass.to_sym)
          "discovery_klass = '#{klass}'"
        end
        type_query = "obj_id = #{meta_id}"
        queries << "(#{[klass_query, type_query].compact.join(' AND ')})"
      end
      @audits = @audits.where(queries.join(" OR "))
    end
  end
  # TODO?
  # To search for replies for a specific post, select reply checkboxes, but put post-# in the meta
  # (Meta tags should also refer to associated objects, post, user, etc.)

end
