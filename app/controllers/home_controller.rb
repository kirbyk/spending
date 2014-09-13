class HomeController < ApplicationController
  def index
  end

  def bank_login
  end

  def bank_create
    @account = Plaid.call.add_account(params['institution'],
                                      params['user'],
                                      params['pass'],
                                      params['email'])

    respond_to do |format|
      if @account[:code] == 200
        flash[:notice] = "We've gained access"
        format.html { render action: 'transactions', account: @account }
      else
        flash[:notice] = "Something went wrong with the bank login"
        format.html { render action: 'bank_login' }
      end
    end
  end

  def transactions
  end

end
