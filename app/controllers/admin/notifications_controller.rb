# frozen_string_literal: true

module Admin
  class NotificationsController < BaseController
    def index
      authorize Notification

      @pagy, @notifications = pagy(
        policy_scope(Notification).recent.includes(:notifiable)
      )
    end

    def mark_read
      @notification = current_user.notifications.find(params[:id])
      authorize @notification, :mark_read?

      @notification.mark_as_read!
      redirect_back fallback_location: admin_notifications_path, notice: "Notification marked as read."
    end

    def mark_all_read
      authorize Notification, :mark_all_read?

      current_user.notifications.unread.update_all(read_at: Time.current)
      Notification.broadcast_unread_count_for(current_user)
      redirect_to admin_notifications_path, notice: "All notifications marked as read."
    end

    def unread_count
      authorize Notification, :unread_count?

      render json: { count: current_user.notifications.unread.count }
    end
  end
end
