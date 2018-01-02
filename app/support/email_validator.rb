class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << failure_message(options) unless passes_regex(value)
  end

  private

  def failure_message(options)
    options[:message] || 'is not a valid email address'
  end

  def passes_regex(value)
    value =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i
  end
end
