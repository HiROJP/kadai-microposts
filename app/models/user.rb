class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts, dependent: :destroy
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  
  #↓has_many_through↓
  #↓user（ユーザ） → relationships（フォロー（中間テーブル）） → user2（ユーザ）↓
  #through: :rekatuibshuos, source: :follow
  #中間テーブルを経由して相手の情報を取得できるようにするためには through を使用する
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  
  has_many :favorites, dependent: :destroy
  has_many :addfavorits, through: :favorites, source: :micropost , dependent: :destroy
  #has_many :reverses_of_favorite, class_name: 'favorite', foreign_key: 'micropost_id'
  #has_many :favorit_user, through: :reverses_of_favorite, source: :user
  
  def favorit(micropost)
    favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  def unfavorit(micropost)
    favorit = self.favorites.find_by(micropost_id: micropost.id)
    favorit.destroy if favorit
  end
  
  def addfavorit?(micropost)
    self.addfavorits.include?(micropost)
  end
  
end
  
#id = Micropost.find(1)

#user = User.find(4)
#id = Micropost.find(2)
#user.addfavorit?(id)

#password_digest カラムを用意し、モデルファイルに has_secure_password を記述すれば、
#ログイン認証のための準備を良しなに用意してくれると覚えておきましょう。

#has_secure_password は暗号化もしてくれますが、暗号化のために bcrypt Gem が必要です。

#def follow では、unless self == other_user によって、フォローしようとしている other_user が自分自身ではないかを検証しています。
#self には user.follow(other) を実行したとき user が代入されます。
#つまり、実行した User のインスタンスが self です。
#更に self.relationships.find_or_create_by(follow_id: other_user.id) は、
#見つかれば Relationshipモデル（クラス）のインスタンスを返し、
#見つからなければ self.relationships.create(follow_id: other_user.id) としてフォロー関係を保存(create = build + save)することができます。
#これにより、既にフォローされている場合にフォローが重複して保存されることがなくなります。


