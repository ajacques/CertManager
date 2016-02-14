class Settings::Group
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def class_name
    self.class.name.split('::').last.underscore
  end

  def self.config_keys(*keys)
    keys.each do |key|
      define_method(key) do
        config_value(key)
      end
    end
  end

  private

  def config_value(key)
    val = Setting.find_by(config_group: class_name, key: key)
    val.value if val
  end
end
