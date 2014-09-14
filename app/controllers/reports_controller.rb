class ReportsController < ApplicationController
  def index
    @categories = Category.all.sort_by { |cat| cat.transactions.count }.reverse
    @top_five = @categories.take 5
  end

  def graph
    @category = Category.find params[:cat_id]

    @n_weeks = 5

    @weekly_avgs = []
    honest_avg = @category.transactions.map{|t| t.amount}.inject(:+) / @n_weeks
    @total_avg = []
    @n_weeks.times do |i|
      this_time = @category.transactions.where(['date_completed > ? AND date_completed < ?', i.weeks.ago, (i-1).weeks.ago])
      if this_time.empty?
        avg = 0
      else
        avg = this_time.map{|t| t.amount}.inject(:+) / this_time.count.to_f
      end
      @weekly_avgs[i] = avg
      @total_avg[i]   = honest_avg
    end
  end
end
