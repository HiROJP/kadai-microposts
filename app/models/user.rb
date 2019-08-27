class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
end

#password_digest カラムを用意し、モデルファイルに has_secure_password を記述すれば、
#ログイン認証のための準備を良しなに用意してくれると覚えておきましょう。

#has_secure_password は暗号化もしてくれますが、暗号化のために bcrypt Gem が必要です。