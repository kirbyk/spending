class HomeController < ApplicationController
  def splash
  end

  def dashboard
    @institutions =  '<option value="amex">American Express</option>
                      <option value="bofa">Bank of America</option>
                      <option value="chase">Chase</option>
                      <option value="citi">Citi</option>
                      <option value="us">US Bank</option>
                      <option value="usaa">USAA</option>
                      <option value="wells">Wells Fargo</option>'.html_safe
  end

  def bank_create
    @account = Plaid.call.add_account(params['institution'],
                                      params['user'],
                                      params['pass'],
                                      params['email'])

    @user = current_user
    respond_to do |format|
      if @account[:access_token].present?
        @user.plaid_access_token = @account[:access_token]
        @user.save
        flash[:success] = "We've gained access"
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

end
