class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << fail_message unless valid?(value)
  end

  private

  def valid?(value)
    value =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i
  end

  def fail_message
    options[:message] || 'is not a valid email address'
  end
end
