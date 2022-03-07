class User < ApplicationRecord

  has_many :posts, dependent: :destroy

  has_many :chat_room_users
  has_many :chat_rooms,through: :chat_room_users
  has_many :chat_messages

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 }
  validates :self_introduction, length: { maximum: 500 }

  # CarrierWave
  mount_uploader :profile_photo, ProfilePhotoUploader

  def update_without_current_password(params, *options)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end
end
