ActiveRecord::Schema.class_eval do
  def enable_extension(*args)
    # no-op: allow schema.rb files from newer versions of Rails to run
  end
end
