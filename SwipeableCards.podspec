Pod::Spec.new do |s|

s.name         = "SwipeableCards"
s.version      = "1.1.1"
s.license      = "Copyright (c) 2016 Ding"
s.summary      = "A containner of views (like cards) can be dragged!"
s.homepage     = "https://github.com/DingHub/SwipeableCards"
s.license      = "MIT"
s.author       = { "DingHub" => "love-nankai@163.com" }
s.source       = { :git => "https://github.com/DingHub/SwipeableCards.git", :tag => "1.1.1" }
s.source_files  = "source/SwipeableCards{.swift}"
s.platform     = :ios
s.platform     = :ios, "8.0"
s.requires_arc = true

end