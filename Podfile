platform :tvos, '9.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

target 'status-board' do
    pod 'Alamofire'
    pod 'RealmSwift'
    pod 'Decodable'
end

plugin 'cocoapods-keys', {
  :project => "status-board",
  :keys => [
    "TrimetAPIKey"
  ]}
