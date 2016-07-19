class Vote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true
  belongs_to :voter, class_name: 'User'

  validates :voteable, :voter, :vote, presence: true

  scope_procedure :voteable_eq, lambda { |v| voteable_type_eq(v.class.base_class.name).voteable_id_eq(v.id) }
end
