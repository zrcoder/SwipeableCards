Pod::Spec.new do |s|

s.name         = "SwipeableCards"
s.version      = "1.0.0"
s.license      = "Copyright (c) 2016 Ding"
s.summary      = "A containner of views (like cards) can be dragged!"
s.homepage     = "tps://github.com/DingHub/SwipeableCards"
s.license      = "MIT"
s.author       = { "DingHub" => "love-nankai@163.com" }
s.source       = { :git => "tps://github.com/DingHub/SwipeableCards.git", :tag => "1.0.0" }
s.source_files  = "source/SwipeableCards{.swift}"
s.platform     = :ios
s.platform     = :ios, "7.0"
s.requires_arc = true

end