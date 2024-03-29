require 'csv'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true
  validates :username, uniqueness: {
    message: "has already been taken"
  }
  validates :username, :length => { :in => 6..30 }

  include PgSearch::Model

  has_many :projects, dependent: :destroy
  has_many :volunteers, dependent: :destroy
  has_many :volunteered_projects, through: :volunteers, source: :project, dependent: :destroy
  has_many :conversations

  has_many :offers
  acts_as_taggable_on :skills

  has_many :office_hours
  has_many :participates_in_office_hours

  pg_search_scope :search, against: %i(name email about location level_of_availability)

  def used_project?(project)
    if project.user_id == self.id
      return true
    end
    project.user_ids.each do |value|
      if value['username'] == self.username
        return true
      end
    end
    return false
  end

  def has_complete_profile?
    self.about.present? && self.profile_links.present? && self.location.present?
  end

  def has_correct_skills?(project)
    project_skills = project.skills.map(&:name)
    return true if project_skills.include?('Anything')
    (self.skills.map(&:name) & project.skills.map(&:name)).present?
  end

  def is_visible_to_user?(user_trying_view)
    return true if self.visibility == true
    return false if user_trying_view.blank?
    return true if user_trying_view.is_admin?
    return true if user_trying_view == self
    return true if self.future_office_hours.length > 0

    # Check if this user volunteered for any project by user_trying_view.
    self.volunteered_projects.where(user_id: user_trying_view.id).exists?
  end

  def future_office_hours
    self.office_hours.where('start_at > ?', DateTime.now).order('start_at ASC')
  end

  def is_admin?
    ADMINS.include?(self.email) || self.email == 'soham.bhavsar@hotmail.com'
  end

  def to_param
    [id, name.parameterize].join('-')
  end

  def self.to_csv
    attributes = %w{email about profile_links location level_of_availability}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end


  def getUnread
    conversations = Conversation.where('sender_id = (?) OR recipient_id = (?)', self.id, self.id)
    unread = 0
    conversations.each do |convo|
      if !convo.last_message.blank?
        if (convo.last_message.read == false) && (convo.last_message.user_id != self.id)
          unread = unread + 1
        end
      end
    end

    unread
  end

  def getMessageRoute
    conversations = Conversation.where('sender_id = (?) OR recipient_id = (?)', self.id, self.id)
    conversations = conversations.includes(:last_message).order('messages.created_at DESC')
    if conversations.length()>0
      conversations[0]
    else
      nil
    end
  end

  def active_for_authentication?
    super && !self.deactivated
  end
end
