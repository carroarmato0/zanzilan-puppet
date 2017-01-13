class roles::web {

  include profile_base
  include profile_webserver
  include profile_mysql
  include profile_share

}
