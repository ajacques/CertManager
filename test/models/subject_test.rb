require 'test_helper'

class SubjectTest < ActiveSupport::TestCase
  test 'removes empty values' do
    subject = Subject.new CN: 'example.com', O: ''
    assert subject.CN == 'example.com'
    assert subject.O.nil?, 'Empty value should have been nulled'
  end
end
