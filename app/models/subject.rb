class Subject < ActiveRecord::Base
  def to_s
    if self.CN then self.CN else self.OU end
  end
  def to_r509
    subj = R509::Subject.new
    filter_params(Subject.attribute_names).each do |k,v|
      val = self.send(k)
      subj.send("#{k}=", self.send(k)) if val.present? unless k == 'id'
    end
    subj
  end
  def self.from_r509(subject)
    Subject.find_or_initialize_by(filter_params(subject.to_h))
  end

  private
  def self.filter_params(params)
    params.slice(:O, :OU, :S, :C, :CN, :L, :ST)
  end
end
