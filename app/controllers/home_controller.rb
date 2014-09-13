class HomeController < ApplicationController
  protect_from_forgery :except => :plaid_hook
  def splash
  end

  def dashboard
  end

  def plaid_hook
    if params[:code] == "1"
      populate_plaid_transactions params[:access_token]
    elsif params[:code] == 2
      update_plaid_transactions
    end
    head :ok, :content_type => 'text/html'
  end

  def bank_create
    @account = Plaid.call.add_account params['institution'],
                                      params['user'],
                                      params['pass'],
                                      params['email'],
                                      { webhook: 'https://57bc991e.ngrok.com/plaidComplete' }

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
  end

  private

  def update_plaid_transactions
  end

  def populate_plaid_transactions access_token
    user = User.find_by(plaid_access_token: access_token)
    transactions = Plaid.customer.get_transactions(access_token)[:transactions]
    transactions.each do |t|
      category = Category.find_by name: t['category'].last
      Transaction.create user_id:         user.id,
                         category_id:     category.id,
                         data_source:     :plaid,
                         amount:          t['amount'] * 100,
                         date_completed:  t['date'],
                         target_id:       t['name']
    end
  end
  handle_asynchronously :populate_plaid_transactions
end
