class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def format_dollars(num)
    num.to_f / 100
  end
end
