module UserRoleHelper
  
  def is_student?
    cookie_role cookies[:user_id] unless cookies[:user_roles]
    user_roles = cookies[:user_roles].split(",")
    user_roles.include? Role::TYPES[:STUDENT].to_s
  end

  def is_paper_creater?
    cookie_role cookies[:user_id] unless cookies[:user_roles]
    user_roles = cookies[:user_roles].split(",")
    user_roles.include? Role::TYPES[:TEACHER].to_s
  end

  #罗列当前用户的所有权限
  def cookie_role(user_id)
    user = User.find user_id
    roles = user.roles
    user_roles = []
    for role in roles
      user_roles << role.id    
    end if roles
    cookies[:user_roles] = {:value => user_roles.join(","), :path => "/", :secure  => false}
  end
    
end
