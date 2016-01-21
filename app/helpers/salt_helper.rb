module SaltHelper
  def salt_get_minions
    salt = SaltClient.new
    salt.login
    salt.get_minions
  end

  def salt_stat_file(file)
    salt = SaltClient.new
    salt.stat_file('*', file)
  end
end
