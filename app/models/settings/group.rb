class Settings::Group
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::ForbiddenAttributesProtection

  def initialize
    @changed_attributes = []

    load_values # Pre-load setting values
  end

  def class_name
    self.class.name.split('::').last.underscore
  end

  def self.config_keys(*keys)
    keys.each do |key|
      define_method(key) do
        config_value(key)
      end
      define_method("#{key}=") do |value|
        setting = Setting.find_by_key(key) || Setting.new
        setting.key = key
        setting.config_group = class_name
        setting.value = value
        @changed_attributes << setting
      end
      define_method("#{key}_changed?") do
        @changed_attributes.include? key
      end
    end
  end

  def save!
    @changed_attributes.each(&:save!)
  end

  def persisted?
    true
  end

  def assign_attributes(values)
    return unless values
    sanitize_for_mass_assignment(values).each do |k, v|
      send("#{k}=", v)
    end
  end

  private

  def load_values
    settings = Setting.where(config_group: class_name)
    @settings = {}
    settings.each do |setting|
      @settings[setting.key] = setting.value
    end
  end

  def config_value(key)
    return @settings[key] if @settings.has_key? key.to_s
    val = Setting.find_by(config_group: class_name, key: key)
    val.value if val
  end
end
