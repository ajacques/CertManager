class SettingSet
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::ForbiddenAttributesProtection

  def initialize
    @changed_attributes = []
  end

  def method_missing(meth, *args)
    if meth[-1] == '='
      method = meth[0...-1]
      setting = Setting.find_by_key(method) || Setting.new
      setting.key = method
      setting.value = args[0]
      @changed_attributes << setting
    elsif meth.to_s.end_with? '_changed?'
      @changed_attributes.include? meth[0...-9].to_sym
    else
      setting = Setting.find_by_key(meth)
      setting.value if setting
    end
  end

  def save!
    @changed_attributes.each(&:save!)
  end

  def assign_attributes(values)
    sanitize_for_mass_assignment(values).each do |k, v|
      send("#{k}=", v)
    end
  end

  def persisted?
    true
  end
end
