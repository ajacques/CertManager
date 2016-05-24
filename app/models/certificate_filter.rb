class CertificateFilter
  include ActiveRecord::Validations
  include ActiveRecord::Sanitization
  include ActiveRecord::AttributeAssignment

  def initialize(opts = {})
    @result_set = Certificate.with_everything.paginate(page: nil)
    assign_attributes(opts)
  end

  def query=(input)
    @result_set = @result_set.where('("subjects"."CN" LIKE ?)', "%#{input}%")
  end

  def page=(input)
    @result_set = @result_set.paginate(page: input)
  end

  def issuer=(input)
    @result_set = @result_set.where(issuer_id: input).where('certificates.issuer_id != certificates.id')
  end

  def expiring_in(input)
    @result_set = @result_set.expiring_in input.to_i.seconds
  end

  def order_by_cn
    @result_set = @result_set.order('"subjects"."CN" ASC')
  end

  def to_results
    @result_set
  end
end
