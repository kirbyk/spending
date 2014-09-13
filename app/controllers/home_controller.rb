class HomeController < ApplicationController
  before_filter :get_plaid_access_token, only: [:mfa, :dashboard, :mfa_save]

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

    @transactions = Plaid.customer.get_transactions(@p_token)[:transactions] if @p_token
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
        flash[:success] = "Great, now check your email for identification code."
        format.html { redirect_to mfa_new_path }
      else
        flash[:notice] = "Something went wrong with the bank login"
        format.html { redirect_to dashboard_path }
      end
    end
  end

  def mfa_new
  end

  def mfa_save
    @account = Plaid.customer.mfa_step(@p_token, params[:id_code])

    @user = current_user
    respond_to do |format|
      if @account[:access_token].present?
        @user.mfa_verified = true;
        @user.save
        flash[:success] = "You've successfully connected your bank!"
        format.html { redirect_to dashboard_path }
      else
        flash[:notice] = "Something went wrong with the bank login"
        format.html { redirect_to mfa_new_path }
      end
    end
  end

  private

  def get_plaid_access_token
    @p_token = current_user.plaid_access_token
  end

end
