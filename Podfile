# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
inhibit_all_warnings!

target 'YouTubeListener' do

  # Pods for YouTubeListener
  pod 'Masonry'
  pod 'XCDYouTubeKit',
  :git => 'https://github.com/kravtsovguy/XCDYouTubeKit.git'

	target 'YouTubeListenerTests' do
		pod 'Expecta'
		pod 'OCMock'
	end

end

# Disable Code Coverage for Pods projects
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        end
    end
end