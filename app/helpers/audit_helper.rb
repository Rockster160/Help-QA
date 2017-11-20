module AuditHelper

  def set_audit_filters
    @audits = Sherlock.order(created_at: :desc).page(params[:page]).per(50)
    dicovery_type_filter = current_filter[:discovery_types].to_a.map(&:to_sym)
    dicovery_klass_filter = current_filter[:discovery_klasses].to_a.map(&:to_sym)
  end
  # To search for replies for a specific post, select reply checkboxes, but put post-# in the meta
  # (Meta tags should also refer to associated objects, post, user, etc.)

end
