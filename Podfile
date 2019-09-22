platform :osx, '10.14'
install! 'cocoapods',
  :generate_multiple_pod_projects => true,
  :incremental_installation => true

target 'Dynamic Dark Mode' do
  use_modular_headers!
  inhibit_all_warnings!
  # Pods for Dynamic Dark Mode
  pod 'Solar', :git => 'https://github.com/paulw11/Solar.git'
  pod 'Schedule', :git => 'https://github.com/luoxiu/Schedule.git'
  pod 'MASShortcut'
  pod 'LetsMove'
  pod 'Sparkle'
  
  # https://github.com/sparkle-project/Sparkle/issues/1389#issuecomment-487934667
  post_install do |installer|
    # Sign the Sparkle helper binaries to pass App Notarization.
    system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/fileop")
    system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/Autoupdate")
  end
end
