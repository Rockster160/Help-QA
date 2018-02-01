Dir[Rails.root.join('lib/core_extensions/*.rb')].each { |file| require file }

if Rails.env.archivedev?
  module Rails
    class ActiveSupport::StringInquirer
      def archive?; true; end
    end
  end
end
