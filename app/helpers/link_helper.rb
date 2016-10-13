module LinkHelper
  def untrusted_party_link(name, url, opts = {}, &block)
    link_to name, url, opts.merge(target: '_blank', rel: 'noopener', &block)
  end
end
