
Pod::Spec.new do |s|

  s.name         = "AKImagePickerController"
  s.version      = "1.0.8"
  s.summary      = "A short description of AKImagePickerController."

  s.description  = "This is an ImagePickerController"

  s.homepage     = "https://github.com/alexsanderkhitev/AKImagePickerController"

  s.license      = "MIT"

  s.author             = { "Alexsander Khitev" => "alexsanderskywork@gmail.com" }
  s.social_media_url   = "https://twitter.com/devkhitev"

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/alexsanderkhitev/AKImagePickerController.git", :tag => s.version }

  s.source_files  = 'AKImagePickerController/**/*.{h,m,swift}'

  s.resources = "AKImagePickerController/**/*.{png,jpeg,jpg,storyboard,xib,Images.xcassets}"
  s.resource_bundle = {"Images" => ["Images.xcassets"]}

  s.requires_arc = true

end
