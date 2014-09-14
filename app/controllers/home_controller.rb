class HomeController < ApplicationController
  protect_from_forgery :except => :plaid_hook
  before_filter :get_plaid_access_token, only: [:mfa, :dashboard, :mfa_save]

  def splash
    redirect_to dashboard_path if current_user
  end

  def dashboard
    @institutions =  '<option value="amex">American Express</option>
                      <option value="bofa">Bank of America</option>
                      <option value="chase">Chase</option>
                      <option value="citi">Citi</option>
                      <option value="us">US Bank</option>
                      <option value="usaa">USAA</option>
                      <option value="wells">Wells Fargo</option>'.html_safe

    @transactions = Transaction.all.order 'date_completed DESC'
  end

  def plaid_hook
    if params[:code] == '1'
      populate_plaid_transactions params[:access_token]
    elsif params[:code] == '2'
      update_plaid_transactions
    end
    head :ok, :content_type => 'text/html'
  end

  def bank_create
    webhook_url = 'http://spending.me'
    if Rails.env.development?
      webhook_url = 'https://57bc991e.ngrok.com'
    end
    @account = Plaid.call.add_account params['institution'],
                                      params['user'],
                                      params['pass'],
                                      params['email'],
                                      { webhook: "#{webhook_url}/plaidComplete",
                                        login_only: true }

    @user = current_user
    respond_to do |format|
      if @account[:access_token].present?
        @user.plaid_access_token = @account[:access_token]
        @user.institution = params[:institution]
        @user.save
        flash[:success] = "Great, now check your email for identification code."
        if params['institution'] == 'chase'
          format.html { redirect_to mfa_new_path }
        else
          @user.verified = true;
          @user.save
          format.html { redirect_to dashboard_path }
        end
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
        @user.verified = true;
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

  def venmo_transactions
    venmo_transactions = Transaction.venmo

    venmo_transactions.each do |transaction|
      transaction['category_id'] = category_id_from_note(transaction['note'])
      transaction['date'] = transaction['date_completed'].to_s.split(' ')[0]
    end
  end

  def category_id_from_note(note)
    words = note.split(' ')

    words.each_with_index do |word, i|
      if word[0] == '#' || i == words.length-1
        hashtag = word[1..(word.length-1)]
        tag = Tag.find_by(name: word)
        if tag.present?
          return tag.category.id
        end
        category = Category.find_by_name(hashtag.titleize(exclude: ['and']))
        return category.id if category
      end
    end
  end

end
