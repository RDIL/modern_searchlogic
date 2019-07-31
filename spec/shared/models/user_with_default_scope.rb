class UserWithDefaultScope < User
  default_scope { where('username is not null') }
end
