class ReportsController < ApplicationController
  def money_math
    # Group disputes by currency and status
    @aggregates = Dispute.joins(:charge)
                         .group("charges.currency", :status)
                         .sum(:amount_cents)

    # Calculate total disputed volume per currency
    @total_volume = Dispute.joins(:charge)
                           .group("charges.currency")
                           .sum(:amount_cents)
  end

  def time_zone
    # For this exercise, we show counts for today vs yesterday in different TZs
    # Note: In a real app we'd let user select TZ. Here we hardcode a few interesting ones.

    @zones = [ "UTC", "America/New_York", "Asia/Tokyo", "Europe/London" ]
    @data = {}

    @zones.each do |zone_name|
      zone = ActiveSupport::TimeZone[zone_name]
      today_range = zone.now.all_day

      @data[zone_name] = {
        count: Dispute.where(created_at: today_range).count,
        volume: Dispute.joins(:charge).where(created_at: today_range).sum(:amount_cents),
        local_time: zone.now.to_fs(:short)
      }
    end
  end

  def daily_volume
    @from = params[:from].present? ? Date.parse(params[:from]) : 30.days.ago.to_date
    @to = params[:to].present? ? Date.parse(params[:to]) : Date.today

    range = @from.beginning_of_day..@to.end_of_day

    @disputes_by_day = Dispute.where(created_at: range)
                              .group("DATE(created_at)")
                              .order("DATE(created_at)")
                              .pluck("DATE(created_at)", Arel.sql("COUNT(*)"), Arel.sql("SUM(amount_cents)"))
                              .map { |date, count, amount| { date: date, count: count, amount: amount } }

    respond_to do |format|
      format.html
      format.json { render json: @disputes_by_day }
    end
  end

  def time_to_decision
    # Fetch all closed disputes
    disputes = Dispute.where(status: [ :closed_won, :closed_lost ])
                      .select(:id, :created_at, :updated_at)

    # Group by week and calculate durations
    grouped_durations = disputes.group_by { |d| d.created_at.beginning_of_week.to_date }
                                .transform_values { |ds| ds.map { |d| d.updated_at - d.created_at } }

    @stats = grouped_durations.map do |week, durations|
      sorted = durations.sort
      count = sorted.length

      p50 = sorted[(count * 0.50).ceil - 1] || 0
      p90 = sorted[(count * 0.90).ceil - 1] || 0

      {
        week: week,
        p50_days: (p50 / 1.day).round(2),
        p90_days: (p90 / 1.day).round(2),
        count: count
      }
    end.sort_by { |s| s[:week] }
  end
end
