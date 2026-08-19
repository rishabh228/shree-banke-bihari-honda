# frozen_string_literal: true

# After a migration, development reloads model files but keeps a stale schema
# cache. Rails 8 enums then raise "Undeclared attribute type". Refresh columns
# on each reload so new billing fields (einvoice_status, receipt_head, etc.)
# are visible without restarting the server.
if Rails.env.development?
  Rails.application.config.to_prepare do
    next unless ApplicationRecord.connected?

    ApplicationRecord.connection.schema_cache.clear!
    ApplicationRecord.descendants.each(&:reset_column_information)
  rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::NoDatabaseError
    nil
  end
end
