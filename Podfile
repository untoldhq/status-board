platform :tvos, '10.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

target 'status-board' do
    pod 'Alamofire'
    pod 'RealmSwift'
    pod 'Decodable'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "3.0"
    end
  end
end

plugin 'cocoapods-keys', {
  :project => "status-board",
  :keys => [
    "TrimetAPIKey"
  ]}
