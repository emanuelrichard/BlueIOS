use_frameworks!

target 'BlueIOSNew' do
  platform :ios, '15.6'

  # Pods para Banheira
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
  pod 'DropDown'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
    end

    # Ajuste adicional para o target BoringSSL-GRPC
    if target.name == 'BoringSSL-GRPC'
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
      end
    end
  end
end