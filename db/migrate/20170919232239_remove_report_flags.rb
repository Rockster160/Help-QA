class RemoveReportFlags < ActiveRecord::Migration[5.0]
  def change
    drop_table :report_flags
    
  end
end
