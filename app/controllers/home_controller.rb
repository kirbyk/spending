class HomeController < ApplicationController
  def splash
  end

  def dashboard
  end

  def bank_create
    @account = Plaid.call.add_account(params['institution'],
                                      params['user'],
                                      params['pass'],
                                      params['email'])

    @user = current_user
    respond_to do |format|
      if @account[:code] == 200
        @user.plaid_access_token = @account[:access_token]
        @user.save
        flash[:notice] = "We've gained access"
        format.html { redirect_to dashboard_path }
      else
        flash[:notice] = "Something went wrong with the bank login"
        format.html { redirect_to dashboard_path }
      end
    end
  end

  def transactions
    p_token = current_user.plaid_access_token
    @transactions = Plaid.customer.get_transactions(p_token)[:transactions]
    @transactions.push(venmo_transactions).flatten!
    @transactions.sort_by! { |t| t['date'] }.reverse!
  end

  private

  def venmo_transactions
    venmo_transactions = Transaction.where(data_source: 'venmo')

    venmo_transactions.each do |transaction|
      transaction['date'] = transaction['date_completed'].to_s.split(' ')[0]
    end
  end
end
