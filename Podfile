use_frameworks!

target 'BlueIOSNew' do
  platform :ios, '14.2'

  # Pods for Banheira
  pod 'DCKit'
  pod 'MSCircularSlider'
  pod 'FlexColorPicker'
  pod 'CocoaMQTT'
  pod 'RealmSwift', '~> 10.18.0'
  pod 'Starscream', '~> 4.0.0'
  pod 'IQKeyboardManagerSwift'
  pod 'FirebaseAnalytics'
  pod 'FirebaseMessaging'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.2'
               end
          end
   end
end
