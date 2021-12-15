class PurchaseRecordsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :new]
  before_action :move_to_index, only: [:index, :new]

  def index
    @item = Item.find(params[:item_id])
    @order = Order.new
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(purchase_params)
    @item = Item.find(params[:item_id])
    if @order.valid?
      pay_item
      @order.save
      redirect_to root_path
    else
      render 'index'
    end
  end

  private
  def purchase_params
    params.require(:order).permit(:post_number, :prefecture_id,:purchaser_city, :purchaser_address,  
                                            :purchaser_building, :telephone_number).merge(user_id: current_user.id, item_id: params[:item_id], token: params[:token])
  end

  def pay_item
    Payjp.api_key = "sk_test_04916d6abbb950ab15ae84d5"  # 自身のPAY.JPテスト秘密鍵を記述しましょう
    Payjp::Charge.create(
      amount: @item.price,  # 商品の値段
      card: purchase_params[:token],    # カードトークン
      currency: 'jpy'                 # 通貨の種類（日本円）
    )
  end

  def move_to_index
    if  @item.present?
    redirect_to root_path
    end
  end


end