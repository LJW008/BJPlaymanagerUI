Pod::Spec.new do |s|
  s.name = "BJPlayerManagerUI"
  s.version = "1.4.5"
  s.summary = "BJPlayerManagerUI."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"辛亚鹏"=>"xinyapeng@baijiahulian.com"}
  s.homepage = "git@github.com:LJW008/BJPlaymanagerUI.git"
  s.description = "TODO: Add long description of the pod here."
  s.xcconfig = {"GCC_PREPROCESSOR_DEFINITIONS"=>"$(inherited) PODSPEC_NAME=BJPlayerManagerUI PODSPEC_VERSION=1.4.5"}
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/BJPlayerManagerUI.embeddedframework/BJPlayerManagerUI.framework'
end
