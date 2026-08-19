# frozen_string_literal: true

class MediaAsset < ApplicationRecord
  has_one_attached :file

  validates :title, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :images, -> { where(file_type: "image") }
  scope :documents, -> { where(file_type: "document") }

  after_commit :detect_file_type, on: :create

  private

  def detect_file_type
    return unless file.attached?

    content_type = file.content_type.to_s
    update_column(:file_type, content_type.start_with?("image/") ? "image" : "document")
  end
end
